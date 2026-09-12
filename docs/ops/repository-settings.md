# Repository settings baseline

Các setting này không nằm hết trong Git, nên phải cấu hình và lưu evidence (ảnh/link/audit output). Rà
khi tạo repo, đổi visibility/owner, sau incident và tối thiểu mỗi quý.

## Access và governance

- [ ] Owner/admin tối thiểu cần thiết; 2FA/SSO theo tổ chức; review dormant/outside collaborators.
- [ ] Default branch rõ; cấm force-push/delete; mọi thay đổi qua PR.
- [ ] Required checks theo project profile; branch up-to-date hoặc merge queue khi concurrency cao.

### Required checks — nguồn sự thật (đối chiếu tự động)

`.github/workflows/ci.yml` có nhiều job **phẳng, không `needs:`** — không có job tổng hợp để gom, nên
branch protection phải liệt kê **đúng tên từng job**. Danh sách dưới đây LÀ nguồn sự thật duy nhất cho
tên job cần bật "Require status checks to pass" trên GitHub (Settings → Branches → main). Đổi tên/xoá/thêm
job trong `ci.yml` hoặc `pr-policy.yml` thì sửa danh sách này **trong cùng PR** —
`scripts/check-ci-policy.sh` đối chiếu hai chiều và chặn CI nếu lệch (job `docs-consistency`).

Không liệt kê job của `codeql.yml`, `secret-scan.yml`, `dependency-review.yml`, `lighthouse-ci.yml`,
`release.yml`, `verify-dropins.yml` ở đây — các workflow đó không thuộc cổng merge bắt buộc cho mọi PR
(scheduled/optional/advisory theo cấu hình từng dự án đích); bật required check cho chúng là lựa chọn
riêng của mỗi dự án, không phải bất biến của khung.

```
ci.yml: framework-lint
ci.yml: docs-consistency
ci.yml: copy-framework-smoke
ci.yml: quality
ci.yml: source-hygiene
ci.yml: e2e
pr-policy.yml: metadata
```

- [ ] Require conversation resolution; code-owner approval cho vùng nhạy cảm.
- [ ] Không cho workflow tự approve PR; default `GITHUB_TOKEN` read-only.
- [ ] Chọn squash/rebase/merge strategy và auto-delete branch.

## Security

- [ ] Dependency graph, Dependabot alerts/security updates và dependency review.
- [ ] Secret scanning + push protection; private vulnerability reporting cho public repo.
- [ ] Code scanning phù hợp ngôn ngữ; security policy/contact đã điền.
- [ ] Actions chỉ từ nguồn tin cậy; pin full SHA; review Dependabot action updates.
- [ ] Self-hosted runner được cô lập; không chạy untrusted fork code trên runner có secret/network nhạy cảm.
- [ ] Audit log/vulnerability alerts có owner và SLA.

## Environments và deploy

- [ ] dev/staging/prod tách dữ liệu, credentials và cloud account/project khi khả thi.
- [ ] Production environment có required reviewer, branch/tag rules và concurrency.
- [ ] Dùng OIDC short-lived credentials thay long-lived cloud secret khi provider hỗ trợ.
- [ ] Secret scope tối thiểu; rotation/revocation owner; không đưa secret vào PR workflow từ fork.
- [ ] Deploy ghi artifact digest/version/provenance; có health check và rollback.

## Community/project metadata

- [ ] Description, topics, homepage, README, license và template-repository setting đúng.
- [ ] CONTRIBUTING, SECURITY; Code of Conduct/Support/Governance khi public hoặc nhiều contributor.
- [ ] Discussions/Issues phù hợp; Issue Forms không chứa URL của repo template nguồn.
- [ ] Citation/funding chỉ thêm khi project thực sự cần.

## Evidence

| Setting/control | Value | Owner | Verified date | Evidence/link | Next review |
| --- | --- | --- | --- | --- | --- |
| | | | | | |
