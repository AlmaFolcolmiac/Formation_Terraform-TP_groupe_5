graph TD
    subgraph Internet["Internet (Public)"]
        User((Utilisateur))
    end
 
    subgraph AWS_Region["Région AWS (eu-west-1)"]
        subgraph VPC["VPC (10.30.0.0/16)"]
            subgraph AZ1["Zone de Disponibilité A (AZ1)"]
                subgraph Public_Subnet_A["Subnet Public A"]
                    ALB[Application Load Balancer]
                    NAT[NAT Gateway]
                end
                subgraph Private_App_Subnet_A["Subnet Privé App A"]
                    EC2_A[EC2 Nextcloud - ASG]
                end
                subgraph Private_DB_Subnet_A["Subnet Privé DB A"]
                    RDS_Master[(RDS PostgreSQL 16.4)]
                end
            end
 
            subgraph AZ2["Zone de Disponibilité B (AZ2)"]
                subgraph Public_Subnet_B["Subnet Public B"]
                    ALB_Standby[ALB Listener/Node]
                end
                subgraph Private_App_Subnet_B["Subnet Privé App B"]
                    EC2_B[EC2 Nextcloud - ASG]
                end
                subgraph Private_DB_Subnet_B["Subnet Privé DB B"]
                    RDS_Standby[(RDS Standby)]
                end
            end
            IGW[Internet Gateway]
            VPCE_S3[[VPC Endpoint S3 - Gateway]]
            VPCE_SM[[VPC Endpoint Secrets Manager - Interface]]
        end
 
        subgraph Global_Services["Services Transverses (Sécurité & Stockage)"]
            S3_Primary[(S3 Primary Storage - KMS)]
            S3_Logs[(S3 ALB Access Logs - AES256)]
            KMS[[KMS CMK - Chiffrement]]
            Secrets[[Secrets Manager - Mots de passe]]
            ACM[[ACM - Certificat HTTPS]]
            IAM[[IAM - Instance Profile / Roles]]
        end
    end
 
    %% Interactions
    User -- HTTPS:443 --> ALB
    ALB -- Port 80/8080 --> EC2_A
    ALB -- Port 80/8080 --> EC2_B
    EC2_A -- Port 5432 --> RDS_Master
    EC2_B -- Port 5432 --> RDS_Master
    %% Connexions Services
    ALB -- Envoi Logs --> S3_Logs
    EC2_A & EC2_B -- Stockage Fichiers --> S3_Primary
    EC2_A & EC2_B -- Récupération Secrets --> Secrets
    S3_Primary & RDS_Master & Secrets -- Protégés par --> KMS
    NAT -- Sortie Internet --> IGW
    ALB -- SSL/TLS --> ACM
    EC2_A & EC2_B -- Permissions --> IAM
