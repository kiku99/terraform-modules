# Gemini CLI Project Mandates - Terraform Modules

이 파일은 `terraform-modules` 프로젝트의 핵심 원칙과 가이드라인을 담고 있습니다. 모든 작업은 이 가이드를 최우선으로 준수해야 합니다.

## 1. 프로젝트 개요
이 프로젝트는 AWS, GCP, Azure 및 Kubernetes를 위한 재사용 가능한 Terraform 모듈 컬렉션입니다. YAML 기반의 선언적 구성을 통해 인프라를 효율적으로 관리하는 것을 목표로 합니다.

## 2. 모듈 설계 원칙
- **Single Config Object**: 모든 모듈은 단일 `config` 변수를 통해 설정을 전달받습니다. 이는 YAML 파일을 `yamldecode`하여 모듈에 직접 전달하기 위함입니다.
- **Optional Fields**: `config` 객체 내의 선택적 필드는 `optional()` 함수를 사용하여 정의합니다.
- **Provider Isolation**: 각 클라우드 프로바이더별로 디렉토리를 분리하여 관리합니다 (`aws/`, `gcp/`, `azure/`, `kubernetes/`).

## 3. 파일 명명 규칙 (Naming Conventions)
기존 코드베이스의 일관성을 위해 다음 규칙을 준수합니다.
- **AWS 모듈**: 복수형 사용 (`variables.tf`, `outputs.tf`)
- **GCP/Kubernetes 모듈**: 단수형 사용 (`variable.tf`, `output.tf`)
- **리소스 정의**: 항상 `main.tf` 파일에 주 리소스를 정의합니다.

## 4. 모듈 개발 가이드
- **변수 정의 (variables.tf / variable.tf)**:
  ```hcl
  variable "config" {
    type = object({
      name = string
      # ... 기타 필드
      tags = optional(map(string), {})
    })
  }
  ```
- **출력 (outputs.tf / output.tf)**: 다른 모듈에서 참조할 수 있도록 필요한 리소스 ID나 ARN을 명확히 노출합니다.
- **의존성 관리**: 모듈 간 의존성이 있는 경우 `README.md`에 명시하고, `example/` 구성 시 `depends_on`을 사용하여 실행 순서를 보장합니다.

## 5. 예제 및 테스트
- 새로운 모듈을 추가하거나 변경할 때, `example/` 디렉토리에 해당 변경 사항을 반영한 예제를 업데이트하거나 추가해야 합니다.
- `example/` 내의 `config.yaml`과 `main.tf`를 통해 실제 배포 시나리오를 검증합니다.

## 6. 보안 준수 사항
- **Credentials**: 절대로 AWS Access Key, GCP Service Account Key 등 보안 정보를 코드에 포함하거나 커밋하지 마십시오.
- **Sensitive Data**: SSM Parameter Store (Secure) 등을 활용하여 민감 정보를 관리하고, 외부 블로그 가이드를 참고하여 안전하게 처리합니다.

## 7. 문서화
- 각 모듈의 루트에 있는 `README.md`는 지원하는 기능, 사용법, 의존성 정보를 최신으로 유지해야 합니다.
