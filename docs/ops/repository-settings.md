# Repository settings baseline

Các setting này không nằm hết trong Git, nên phải cấu hình và lưu evidence (ảnh/link/audit output). Rà
khi tạo repo, đổi visibility/owner, sau incident và tối thiểu mỗi quý.

## Access và governance

- [ ] Owner/admin tối thiểu cần thiết; 2FA/SSO theo tổ chức; review dormant/outside collaborators.
- [ ] Default branch rõ; cấm force-push/delete; mọi thay đổi qua PR.
- [ ] Required checks theo project profile; branch up-to-date hoặc merge queue khi concurrency cao.
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
