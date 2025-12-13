# Cloud Club Terraform Modules

다양한 클라우드 프로바이더(AWS, GCP, Azure)를 위한 재사용 가능한 Terraform 모듈 컬렉션입니다.

## 목차

- [지원 모듈](#지원-모듈)
- [사용 방법](#사용-방법)
- [예제](#예제)
- [특별 사항](#특별-사항)

## 지원 모듈

### AWS

- **vpc**: VPC, 서브넷, 라우트 테이블, 인터넷 게이트웨이, NAT 게이트웨이 생성
- **security-group**: 보안 그룹 및 인그레스/이그레스 규칙 관리
- **eks**: Amazon EKS 클러스터, 애드온, 액세스 엔트리, Pod Identity 구성
- **irsa**: IAM Roles for Service Accounts (IRSA) 설정
- **oidc**: OIDC Identity Provider 구성
- **role**: IAM 역할 및 정책 관리
- **s3**: S3 버킷 생성 및 설정
- **ec2**: EC2 인스턴스 생성
- **ecr**: Amazon ECR 리포지토리 생성
- **elb**: Elastic Load Balancer 구성
- **parameter-store**: AWS Systems Manager Parameter Store 관리
  - `plain`: 일반 파라미터
  - `secure`: 암호화된 파라미터
- **cloudfront**: CloudFront 배포 구성

### GCP

- **vpc**: VPC 네트워크 및 서브넷 생성
- **firewall**: 방화벽 규칙 관리
- **gke**: Google Kubernetes Engine 클러스터 생성
- **gcs**: Google Cloud Storage 버킷 생성
- **service-account**: 서비스 계정 및 권한 관리
- **ssl**: SSL 인증서 관리
- **loadbalancer**: HTTPS 로드 밸런서 구성

### Azure

- 현재 지원 모듈 없음

### Kubernetes

- **helm**: Helm 차트 배포

## 사용 방법

### 기본 사용법

모듈을 사용하려면 `source`에 상대 경로를 지정하고 필요한 변수를 전달합니다:

```hcl
module "vpc" {
  source = "../../aws/vpc"
  config = {
    name       = "my-vpc"
    cidr_block = "10.0.0.0/16"
    region     = "ap-northeast-2"
    # ... 기타 설정
  }
}
```

### YAML 기반 구성

대부분의 모듈은 YAML 파일을 통한 선언적 구성 방식을 지원합니다. `example/aws/config.yaml`을 참고하세요.

```hcl
locals {
  config = yamldecode(file("./config.yaml"))
}

module "vpc" {
  source = "../../aws/vpc"
  for_each = { for vpc in local.config.vpc : vpc.name => vpc }
  config = each.value
}
```

## 예제

실제 사용 예제는 `example/` 디렉토리에서 확인할 수 있습니다:

- **AWS 예제**: `example/aws/`

  - EKS 클러스터 구성
  - VPC 및 보안 그룹 설정
  - IRSA 및 Pod Identity 설정
  - Parameter Store 사용
  - ECR 리포지토리 생성

- **GCP 예제**: `example/gcp/`
  - GKE 클러스터 구성
  - VPC 및 방화벽 설정

각 예제 디렉토리에는 `config.yaml` 파일과 `main.tf` 파일이 포함되어 있어 모듈 사용 방법을 참고할 수 있습니다.

## 특별 사항

### Parameter Store Secure 사용 시

암호화된 Parameter Store를 사용할 때는 비밀 키 파일 경로를 지정해야 합니다. 자세한 내용은 아래 링크를 참고하세요:

https://velog.io/@tae2089/Terraform%EC%97%90%EC%84%9C-%EB%B9%84%EB%B0%80-%EB%8D%B0%EC%9D%B4%ED%84%B0-%EC%88%A8%EA%B8%B0%EA%B8%B0

### 모듈 의존성

일부 모듈은 다른 모듈에 의존합니다:

- `eks` 모듈은 `vpc`, `security-group`, `iam_role` 모듈이 필요합니다
- `irsa` 모듈은 `eks` 모듈이 필요합니다
- `security-group` 모듈은 `vpc` 모듈이 필요합니다

모듈 사용 시 `depends_on`을 적절히 설정하세요:

```hcl
module "eks" {
  source = "../../aws/eks"
  # ... 설정
  depends_on = [module.vpc, module.security_group, module.iam_role]
}
```

## 모듈 구조

각 모듈은 다음 구조를 따릅니다:

```
module-name/
├── main.tf      # 주요 리소스 정의
├── variables.tf # 입력 변수 정의
└── outputs.tf  # 출력 값 정의 (선택적)
```

## 기여

모듈 개선이나 새로운 모듈 추가를 환영합니다. Pull Request를 통해 기여해주세요.
