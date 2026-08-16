# Supply-chain và release evidence

Áp mức phù hợp với loại artifact/risk; không tuyên bố SLSA level nếu chưa kiểm đủ requirement.

## Baseline mọi project

- lockfile hoặc dependency resolution có thể tái lập;
- dependency review trên PR và vulnerability update có SLA;
- workflow least privilege, không nội suy input không tin cậy vào shell;
- action bên thứ ba pin full commit SHA và được review;
- build từ clean runner/default branch/tag đã bảo vệ;
- artifact có version, digest và retention;
- release notes, license/notice và rollback/revoke procedure.

## SBOM

Release artifact phân phối ra ngoài hoặc production nên có SBOM CycloneDX/SPDX sinh từ dependency
truth của build. Lưu SBOM cạnh artifact/release; kiểm nó chứa direct/transitive dependencies, version,
license và package identifier. Không dùng một scanner không hiểu ecosystem làm nguồn duy nhất.

## Provenance/attestation

Với artifact đóng gói/container/binary:

1. build bằng workflow version-controlled;
2. sinh provenance/attestation gắn đúng subject digest;
3. ký bằng identity ngắn hạn/OIDC khi hỗ trợ;
4. publish artifact + checksum + SBOM + provenance;
5. verify trước deploy/promotion, không chỉ verify sau release;
6. document builder trust, inputs và limitation.

## Maturity path

| Level nội bộ | Evidence |
| --- | --- |
| SC-0 | CI + lock/dependency scan |
| SC-1 | Release digest + SBOM |
| SC-2 | Hosted build + signed provenance/attestation |
| SC-3 | Verify-before-deploy, isolated builder, policy/exception audit |

Tên nội bộ không thay thế chứng nhận SLSA. Nếu claim SLSA, map và audit theo đúng phiên bản spec.

## Exception

Dependency/action chưa pin hoặc vulnerability chưa vá phải có owner, lý do, compensating control,
expiry và issue. Exception hết hạn tự trở thành blocker release.
