# Repository settings baseline

Các setting này không nằm hết trong Git, nên phải cấu hình và lưu evidence (ảnh/link/audit output). Rà
khi tạo repo, đổi visibility/owner, sau incident và tối thiểu mỗi quý.

## Access và governance

- [ ] Owner/admin tối thiểu cần thiết; 2FA/SSO theo tổ chức; review dormant/outside collaborators.
- [ ] Default branch rõ; cấm force-push/delete; mọi thay đổi qua PR.
- [ ] Required checks theo project profile; branch up-to-date hoặc merge queue khi concurrency cao.

### Required checks — nguồn sự thật (đối chiếu tự động)

**Required checks cần tick trên GitHub (Settings → Branches → main) — chỉ HAI tên** (ADR-0003):
job **`gate`** của `ci.yml`, và job **`metadata`** của `pr-policy.yml`. Hết.

`gate` là job tổng hợp `needs:` mọi job cổng của `ci.yml`, nên thêm job cổng mới **không cần**
sửa cấu hình GitHub nữa — chỉ thêm vào `needs:` của `gate` trong cùng PR.

Khối dưới đây là **bản kê toàn bộ job** của hai workflow đó (không phải danh sách cần tick):
`scripts/check-ci-policy.sh` đối chiếu hai chiều bản kê này với job thật và chặn CI nếu lệch
(job `docs-consistency`), đồng thời kiểm mọi job của `ci.yml` đều có mặt trong `needs:` của `gate`.
Đổi tên/xoá/thêm job thì sửa bản kê này **trong cùng PR**.

Không liệt kê job của `secret-scan.yml`, `dependency-review.yml`, `release.yml` ở đây — các workflow
đó không thuộc cổng merge bắt buộc cho mọi PR (scheduled/optional/advisory theo cấu hình từng dự án
đích); bật required check cho chúng là lựa chọn riêng của mỗi dự án, không phải bất biến của khung.

```
ci.yml: framework-lint
ci.yml: docs-consistency
ci.yml: copy-framework-smoke
ci.yml: gate
pr-policy.yml: metadata
```

- [ ] Require conversation resolution; code-owner approval cho vùng nhạy cảm.
- [ ] Auto-delete branch sau merge (audit 2026-09-12, F-014: ~32 nhánh đã merge còn tồn) —
      **chưa bật thật**, chỉ chủ repo bật được trên GitHub Settings → General → Pull Requests.
      Danh sách 31 nhánh đã tra cứu qua GitHub API xác nhận PR `merged_at` thật (đủ điều kiện xoá,
      tính đến 2026-09-12) — 1 nhánh còn lại (`claude/opusplan-model-config-2ojq58`, PR #28) **closed
      KHÔNG merge**, không xoá:
      `agent/parallel-subagent-workflow`, `agent/template-completeness-research`,
      `agent/unify-standard-project-template`, `claude/3-tier-orchestration-arch-yrhz9h`,
      `claude/apply-guidance-existing-project-2m0roa`, `claude/danh-gia-goi-y-du-an-8kttvi`,
      `claude/dev-framework-setup-82roiy`, `claude/huong-dan-mo-phien-model`,
      `claude/merge-pending-prs-main-1nazh9`, `claude/model-repo-role-capability-8pimv0`,
      `claude/opus-sonnet-config-19lc0x`, `claude/opusplan-mode-check-8j3ney`,
      `claude/opusplan-optimization-150yp1`, `claude/opusplan-shared-config-rm5ru6`,
      `claude/opusplan-token-optimization-ihrkd6`, `claude/pr-merge-workflow-8hmdcv`,
      `claude/process-improvement-agixul`, `claude/project-audit-feature-2jyw07`,
      `claude/project-dev-process-review-5ehlgr`, `claude/project-enhancement-research-hosp8u`,
      `claude/project-evaluation-refinement-8qjmoi`, `claude/project-planning-refinement-ujgfiy`,
      `claude/project-ps-application-dqlgag`, `claude/repo-description-57ynk2`,
      `claude/skills-framework-project-0pvndy`, `claude/software-dev-consulting-vh4t4s`,
      `claude/software-dev-standards-jc776c`, `claude/source-code-optimization-pa1x8c`,
      `claude/template-review-k4lpfy`, `claude/unsupported-projects-rxjrg2`,
      `claude/verify-dropins-ci`. Xoá qua GitHub UI (Settings → Branches, hoặc trang so sánh
      nhánh) hoặc `git push origin --delete <branch>` (auto-mode chặn lệnh này — chạy thủ công).
- [ ] Không cho workflow tự approve PR; default `GITHUB_TOKEN` read-only.
- [ ] Chọn squash/rebase/merge strategy và auto-delete branch.
- [ ] **Require signed commits** (chỉ khi dự án ở ASVS L2+ hoặc nhiều người đóng góp không quen biết
      trực tiếp — xem `docs/framework/industry-standards.md` §C) — không bật mặc định cho mọi dự án.

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
