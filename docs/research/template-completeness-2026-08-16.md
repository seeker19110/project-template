# Research: độ hoàn chỉnh của project template — 2026-08-16

## Phạm vi

Đối chiếu repo với tài liệu chính thức hiện hành, tập trung vào khoảng trống phổ quát; không ép mọi
project dùng cùng stack hoặc bật workflow không phù hợp.

## Nguồn chính

- [GitHub — Best practices for repositories](https://docs.github.com/en/repositories/creating-and-managing-repositories/best-practices-for-repositories):
  README, license, citation, contribution guide và code of conduct giúp truyền đạt kỳ vọng.
- [GitHub — Secure use reference](https://docs.github.com/en/actions/reference/security/secure-use):
  pin action bằng full commit SHA là cách dùng immutable release; least privilege và chống script injection.
- [GitHub — Quickstart for securing repositories](https://docs.github.com/en/code-security/getting-started/quickstart-for-securing-your-repository):
  dependency review làm dependency change hiển thị ngay trong PR.
- [GitHub — Security hardening deployments](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments):
  OIDC và reusable workflows giúp giảm long-lived cloud credentials.
- [GitHub — Security in Actions](https://docs.github.com/en/actions/concepts/security):
  artifact attestations cung cấp evidence cho artifact; cần xử lý script injection và runner trust.
- [OpenSSF SCM Best Practices](https://best.openssf.org/SCM-BestPractices/):
  branch protection, review, read-only workflow token, vulnerability alerts, 2FA, audit và continuous compliance.
- [OpenSSF Scorecard](https://openssf.org/scorecard/): đánh giá security posture cho open-source project.
- [SLSA build levels](https://slsa.dev/spec/v1.1/levels) và
  [build provenance](https://slsa.dev/spec/v1.2/build-provenance): provenance ghi artifact được build
  từ đâu, bằng quy trình/inputs nào; mức cao tăng khả năng chống tampering.

## Hiện trạng tốt đã giữ

- Research-first, 9-stage process, brownfield adoption, completion loop và ADR.
- CI, E2E/a11y/performance, CodeQL, secret scan, Dependabot và release-please.
- SECURITY, CONTRIBUTING, CODEOWNERS, incident response, copy scripts không ghi đè.
- Standard Delivery Contract + Goal/Feature Spec/PR policy trong PR này.

## Khoảng trống và quyết định

| Khoảng trống | Quyết định |
| --- | --- |
| Repository settings nằm ngoài Git | Thêm checklist có evidence, owner và review định kỳ |
| Governance/community health chưa có mẫu | Thêm template tùy chọn; không ép dự án private/solo |
| Threat model/data governance chưa thành artifact | Thêm template và trigger theo risk |
| Supply-chain chưa có maturity path | Thêm Dependency Review mặc định; SBOM/provenance/attestation theo release profile |
| Action pinning chưa thống nhất | Ghi gate + lộ trình pin SHA; không đổi hàng loạt trong PR process |
| Public OSS score chưa có | Scorecard optional cho public OSS; tránh workflow đỏ ở private/unsupported repo |
| Release readiness chưa có sign-off chuẩn | Thêm checklist từ build evidence đến rollback/communications |
| Template drift | Copy smoke kiểm artifact mới; repository settings review theo quý |

## Không bật mặc định và lý do

- **Scorecard workflow:** hữu ích cho public OSS nhưng permissions/reporting không phù hợp mọi private project.
- **SBOM/attestation workflow chung:** artifact path/build system khác theo profile; một workflow giả-universal
  sẽ tạo evidence sai hoặc không có artifact. Contract bắt chọn implementation theo release profile.
- **Bắt hai reviewer:** tốt cho team, không khả thi repo solo; checklist yêu cầu cấu hình theo team/risk.
- **Signed commits bắt buộc:** cần rollout và account/tool support; dùng signed release/tag và vigilant mode
  theo risk thay vì làm template không dùng được.
- **CITATION.cff mặc định:** chỉ cần cho research/public package cần citation.

## Exit criteria của lần nâng cấp

- Một entrypoint contract; governance/security/ops/supply-chain được định tuyến từ đó.
- Artifact có trigger rõ: bắt buộc, theo risk hoặc optional.
- Copy Bash/PowerShell và smoke test mang đủ policy mới sang repo đích.
- CI/docs consistency/drop-in verification xanh.
