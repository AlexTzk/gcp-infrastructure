from diagrams import Diagram, Cluster, Edge
from diagrams.gcp.network import VPC, LoadBalancing, FirewallRules, Router, DNS
from diagrams.gcp.compute import GKE, ComputeEngine
from diagrams.gcp.database import SQL
from diagrams.gcp.devtools import ContainerRegistry
from diagrams.gcp.security import KMS, IAP
from diagrams.gcp.storage import GCS, Filestore
from diagrams.gcp.api import APIGateway
from diagrams.k8s.network import Ingress
from diagrams.k8s.others import CRD
from diagrams.onprem.vcs import Git as Bitbucket

graph_attr = {
    "fontsize": "20",
    "bgcolor": "white",
    "pad": "0.8",
    "splines": "ortho",
    "rankdir": "LR",
    "dpi": "200",
    "nodesep": "0.6",
    "ranksep": "1.0",
}

_c = {"rankdir": "LR"}

with Diagram(
    "mycompany-dev | GCP Infrastructure | europe-west2",
    filename="gcp_infra",
    outformat="png",
    show=False,
    graph_attr=graph_attr,
):
    internet = DNS("Internet")
    iap = IAP("Cloud IAP\n35.235.240.0/20")

    with Cluster("GCP Project: mycompany-project-123456 | europe-west2", graph_attr=_c):

        with Cluster("Load Balancer (module.lbs)", graph_attr=_c):
            lb_ip = LoadBalancing("Static LB IP\n:443 HTTPS")
            ssl = KMS("SSL Cert\nTLS 1.2+ RESTRICTED")
            urlmap = LoadBalancing("URL Map\npublic-loadbalancer")
            lb_ip >> ssl >> urlmap

        with Cluster("Cloud Run (module.cr)", graph_attr=_c):
            cr_svc = ComputeEngine("dev-my-app\nnginxdemos/hello:0.4\nGen2 | 0-1 instances")
            cr_neg = LoadBalancing("Serverless NEG")
            cr_be = LoadBalancing("Backend Svc\nCDN + HTTPS")
            cr_svc >> cr_neg >> cr_be
            urlmap >> Edge(label="CR hosts") >> cr_be

        with Cluster("Secret Manager", graph_attr=_c):
            sm_user = GCS("db-user secret")
            sm_pass = GCS("db-password secret")
            sm_name = GCS("db-name secret")
            # Forces horizontal ranking
            sm_user >> Edge(style="invis") >> sm_pass
            sm_pass >> Edge(style="invis") >> sm_name

        urlmap >> Edge(style="invis") >> cr_svc
        cr_be >> Edge(style="invis") >> sm_user

        with Cluster("VPC: mynet-dev | 10.16.0.0/22", graph_attr=_c):
            router = Router("Cloud Router")
            nat = Router("Cloud NAT\n1 static IP")
            router >> nat

            with Cluster("Private Subnet: mynet-dev-mycompany-private", graph_attr=_c):

                with Cluster("Bastion (module.bastion)", graph_attr=_c):
                    bastion = ComputeEngine("mycompany-dev-bastion\ne2-micro | 10.16.0.10")

                with Cluster("Filestore (module.nfs)", graph_attr=_c):
                    filestore = Filestore("Filestore Instance\nManaged NFS Fileshare\n:2049 | Private Subnet")

                with Cluster(
                    "🔒 PRIVATE GKE Cluster: mycompany-dev-gke (module.gke)\n"
                    "enable_private_nodes=true | enable_private_endpoint=true | master: 172.16.0.0/28",
                    graph_attr=_c,
                ):
                    ctrl = GKE("Control Plane\nPrivate Endpoint Only\nautoscale 1-3 × n2d-standard-4")

                    with Cluster("ingress-nginx namespace", graph_attr=_c):
                        nginx = Ingress("NGINX Ingress\nHelm v4.15.0")

                    with Cluster("external-secrets namespace", graph_attr=_c):
                        ext_sec = CRD("External Secrets Op\nHelm v2.1.0")
                        secret_store = CRD("SecretStore\ngcp-secret-store")
                        ext_secret = CRD("ExternalSecret\npostgres")
                        ext_sec >> secret_store >> ext_secret

                    gke_neg = LoadBalancing("NEG: ingress-nginx\n:80 HTTP")
                    gke_be = LoadBalancing("Backend Svc\nCDN + health :80/healthz")
                    ctrl >> nginx >> gke_neg >> gke_be
                    urlmap >> Edge(label="GKE hosts") >> gke_be

                with Cluster("Cloud SQL (module.sql)", graph_attr=_c):
                    pg = SQL("mycompany-dev-db1\nPostgres 16 | REGIONAL HA\ndb-custom-2-7680 | 250GB PD-SSD")

                ctrl >> Edge(label=":2049 NFS Fileshare") >> filestore
                ctrl >> Edge(label=":5432") >> pg

        ext_secret >> sm_user
        ext_secret >> sm_pass
        ext_secret >> sm_name

        with Cluster("Artifact Registry (module.artifactregistry)", graph_attr=_c):
            ar = ContainerRegistry("mycompany-dev-images\nDocker | europe-west2")

        with Cluster("IAM (module.iam)", graph_attr=_c):
            sa_bb = APIGateway("SA: bitbucket-service-account\nWIF OIDC Pool")
            sa_ext = APIGateway("SA: gke-external-secrets-sa\nWorkload Identity")
            sa_sql = APIGateway("SA: gke-cloudsql-sa\nWorkload Identity")
            sa_bastion = APIGateway("SA: bastion-vm-service-account")
            sa_bb >> Edge(style="invis") >> sa_ext
            sa_ext >> Edge(style="invis") >> sa_sql
            sa_sql >> Edge(style="invis") >> sa_bastion

        with Cluster("Firewall (module.firewall)", graph_attr=_c):
            fw = FirewallRules("6 rules:\nSSH-IAP | GKE→Filestore\nGKE→PG | LB→NGINX\nInternal :80/:443/:8080")

        bitbucket = Bitbucket("Bitbucket Pipelines\n(external / WIF OIDC)")
        bitbucket >> sa_bb >> ar
        sa_ext >> Edge(label="Workload Identity") >> ext_sec
        sa_sql >> Edge(label="Workload Identity") >> ctrl

    internet >> lb_ip
    internet >> iap
    iap >> bastion
