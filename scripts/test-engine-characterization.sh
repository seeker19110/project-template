#!/usr/bin/env bash
# test-engine-characterization.sh — CHARACTERIZATION TEST cho hai hàm đo đạc phức tạp nhất
# của hai engine Python:
#   - scripts/arch-health-radar.py :: scan_codebase_health (+ _scripts_inventory, _spec_quality)
#   - scripts/spec-compiler.py     :: parse_spec_markdown
#
# VÌ SAO TỒN TẠI: hai hàm này là logic ĐO ĐẠC thật của khung (điểm sức khoẻ repo, hợp đồng spec).
# Trước khi hạ độ phức tạp của chúng (radon CC 18 → < 12) phải KHOÁ HÀNH VI TỪNG NHÁNH lại,
# nếu không một diff "gọn hơn" đặt sai chỗ sẽ âm thầm đổi con số mà không cổng nào bắt được.
# Test dựng repo tổng hợp trong thư mục tạm, trỏ ROOT_DIR của module vào đó, gọi THẲNG hàm và
# assert giá trị trả về — không phải "chạy không crash".
#
# KHÔNG viết bằng .py trong scripts/ là CỐ Ý: scripts/test-py-coverage.sh chạy
# `coverage run --source=scripts`, nên mọi file .py nằm trong scripts/ mà không được chính
# test-py-coverage.sh gọi sẽ bị tính 0% và kéo tụt sàn 95%.
#
# Chạy: bash scripts/test-engine-characterization.sh
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

PYTHON_CMD="python3"
command -v python3 >/dev/null 2>&1 || PYTHON_CMD="python"

"$PYTHON_CMD" - "$ROOT" <<'PYEOF'
import importlib.util
import os
import sys
import tempfile
import unittest

ROOT = sys.argv[1]


def _load(name, filename):
    path = os.path.join(ROOT, "scripts", filename)
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


radar = _load("radar_under_test", "arch-health-radar.py")
compiler = _load("compiler_under_test", "spec-compiler.py")


def write(base, rel, text):
    full = os.path.join(base, rel.replace("/", os.sep))
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf-8") as fp:
        fp.write(text)
    return full


class RadarBase(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.repo = self._tmp.name
        self._saved_root = radar.ROOT_DIR
        radar.ROOT_DIR = self.repo
        self.addCleanup(self._restore)

    def _restore(self):
        radar.ROOT_DIR = self._saved_root
        self._tmp.cleanup()


class TestRepoRong(RadarBase):
    """Repo TRỐNG: mọi mẫu số bằng 0 -> pct() trả 100.0, điểm tuyệt đối, không có đề xuất."""

    def test_scan_repo_rong(self):
        data = radar.scan_codebase_health()
        self.assertEqual(data["total_files"], 0)
        self.assertEqual(data["total_lines"], 0)
        self.assertEqual(data["code_lines"], 0)
        self.assertEqual(data["code_comment_lines"], 0)
        self.assertEqual(data["doc_lines"], 0)
        self.assertEqual(data["doc_ratio_pct"], 100.0)
        self.assertEqual(data["file_type_counts"], {})
        self.assertEqual(data["scripts_total"], 0)
        self.assertEqual(data["scripts_covered"], 0)
        self.assertEqual(data["scripts_uncovered"], [])
        self.assertEqual(data["ci_tests"], [])
        self.assertEqual((data["spec_total"], data["spec_good"], data["spec_weak"]), (0, 0, []))
        self.assertEqual(data["large_code_files"], [])
        self.assertEqual(data["large_doc_files"], [])
        self.assertEqual(data["todo_markers"], [])
        self.assertEqual(data["signals"], {
            "gate_coverage": 100.0, "spec_quality": 100.0, "size_discipline": 100.0,
            "comment_density": 100.0, "todo_debt": 100.0,
        })
        self.assertEqual(data["weights"], {"gate": 40, "spec": 20, "size": 15, "comment": 15, "todo": 10})
        self.assertEqual(data["health_score"], 100)
        self.assertEqual(data["recommendations"], [])
        self.assertEqual(radar.generate_recommendations(data),
                         ["Không còn tín hiệu nợ kỹ thuật nào ĐO ĐƯỢC BẰNG CÁC THƯỚC Ở TRÊN."])

    def test_inventory_va_spec_khi_thieu_thu_muc(self):
        self.assertEqual(radar._scripts_inventory(), ([], set(), set()))
        self.assertEqual(radar._spec_quality(), (0, 0, []))

    def test_scripts_dir_rong_khong_co_ci_yml(self):
        os.makedirs(os.path.join(self.repo, "scripts"))
        write(self.repo, "scripts/README.txt", "khong phai script\n")
        self.assertEqual(radar._scripts_inventory(), ([], set(), set()))


class TestRepoCoKhiemKhuyet(RadarBase):
    """Repo có ĐỦ khiếm khuyết: script không cổng, file mã dài, tài liệu dài, spec yếu, TODO."""

    def setUp(self):
        super().setUp()
        write(self.repo, ".github/workflows/ci.yml",
              "jobs:\n  a:\n    steps:\n      - run: bash scripts/test-alpha.sh\n")
        # test-alpha.sh là test CHẠY TRONG CI, thân của nó nhắc beta.sh -> beta.sh được phủ,
        # và beta.py (cùng tên, đuôi .py) cũng được phủ theo luật wrapper.
        write(self.repo, "scripts/test-alpha.sh", "#!/usr/bin/env bash\nbash scripts/beta.sh\n")
        write(self.repo, "scripts/beta.sh", "#!/usr/bin/env bash\n# chu thich\ntrue\n")
        write(self.repo, "scripts/beta.py", "x = 1\n")
        write(self.repo, "scripts/gamma.sh", "#!/usr/bin/env bash\n# TODO: no ky thuat\nTODO khong tinh\n")
        # test-orphan.sh là test nhưng KHÔNG nằm trong ci.yml -> không phải cổng, tự nó uncovered.
        write(self.repo, "scripts/test-orphan.sh", "#!/usr/bin/env bash\ntrue\n")
        write(self.repo, "scripts/long.sh", "#!/usr/bin/env bash\n" + "true\n" * 401)
        write(self.repo, "docs/long.md", "dong\n" * 901)
        write(self.repo, "docs/specs/README.md", "# bo qua\n")
        write(self.repo, "docs/specs/good.md",
              "# Spec tot\n\nFR-1 va AC-2\n\n## 11. Architecture và code touchpoints\n\n- `scripts/beta.sh`\n")
        write(self.repo, "docs/specs/weak.md", "# Spec yeu\n\nkhong co gi\n")
        write(self.repo, "notes", "khong co duoi file\n")
        write(self.repo, "app.js", "// chu thich\nconst a = 1;\n")

    def test_inventory(self):
        all_scripts, covered, ci_tests = radar._scripts_inventory()
        self.assertEqual(all_scripts, ["beta.py", "beta.sh", "gamma.sh", "long.sh",
                                       "test-alpha.sh", "test-orphan.sh"])
        self.assertEqual(covered, {"test-alpha.sh", "beta.sh", "beta.py"})
        self.assertEqual(ci_tests, {"test-alpha.sh"})

    def test_spec_quality(self):
        total, good, weak = radar._spec_quality()
        self.assertEqual((total, good), (2, 1))
        self.assertEqual(weak, [{"file": "docs/specs/weak.md",
                                 "missing": "không có mã FR-/AC-, thiếu mục 11 touchpoints"}])

    def test_scan_tin_hieu_va_danh_sach(self):
        data = radar.scan_codebase_health()
        self.assertEqual(data["scripts_total"], 6)
        self.assertEqual(data["scripts_covered"], 3)
        self.assertEqual(data["scripts_uncovered"], ["gamma.sh", "long.sh", "test-orphan.sh"])
        self.assertEqual(data["ci_tests"], ["test-alpha.sh"])
        self.assertEqual(data["signals"]["gate_coverage"], 50.0)
        self.assertEqual(data["signals"]["spec_quality"], 50.0)
        # file mã: beta.py, beta.sh, gamma.sh, long.sh, test-alpha.sh, test-orphan.sh, app.js = 7
        self.assertEqual(data["signals"]["size_discipline"], round(100.0 * 6 / 7, 1))
        self.assertEqual(data["large_code_files"], [{"file": "scripts/long.sh", "lines": 402}])
        self.assertEqual(data["large_doc_files"], [{"file": "docs/long.md", "lines": 901}])
        # CHỈ dấu nằm ngay sau '#' hoặc '//' mới tính; dòng "TODO khong tinh" bị bỏ qua.
        self.assertEqual(data["todo_markers"], [{"file": "scripts/gamma.sh", "line": 2}])
        self.assertEqual(data["signals"]["todo_debt"], 90.0)
        # docs/long.md 901 + specs/README.md 1 + specs/good.md 7 + specs/weak.md 3
        self.assertEqual(data["doc_lines"], 901 + 1 + 7 + 3)
        self.assertEqual(data["file_type_counts"][".sh"], 5)
        self.assertEqual(data["file_type_counts"]["(no-ext)"], 1)
        self.assertEqual(data["file_type_counts"][".yml"], 1)

    def test_de_xuat_tro_vao_viec_cu_the(self):
        data = radar.scan_codebase_health()
        recs = radar.generate_recommendations(data)
        self.assertEqual(recs[0], "Thêm test (và nối vào `ci.yml`) cho: "
                                  "`scripts/gamma.sh`, `scripts/long.sh`, `scripts/test-orphan.sh`")
        self.assertIn("Bổ sung cho `docs/specs/weak.md`: "
                      "không có mã FR-/AC-, thiếu mục 11 touchpoints", recs)
        self.assertIn("File mã `scripts/long.sh` dài 402 dòng (> 400) — cân nhắc tách", recs)
        self.assertIn("Giải quyết hoặc chuyển thành issue: `scripts/gamma.sh:2`", recs)

    def test_bao_cao_markdown_in_du_muc_canh_bao(self):
        data = radar.scan_codebase_health()
        data["recommendations"] = radar.generate_recommendations(data)
        report = radar.format_markdown_report(data)
        self.assertIn("### ⚠️ Script KHÔNG có cổng bảo vệ (3)", report)
        self.assertIn("### ⚠️ Spec chưa đạt chuẩn (1)", report)
        self.assertIn("### File mã dài (> 400 dòng)", report)
        self.assertIn("### File tài liệu dài (> 900 dòng — thông tin, KHÔNG trừ điểm)", report)


class TestRadarCaBien(RadarBase):
    """Ca biên: thư mục loại trừ, file chỉ toàn chú thích, mật độ chú thích vượt mốc 15%."""

    def test_bo_qua_thu_muc_loai_tru(self):
        write(self.repo, "node_modules/x.js", "var a = 1;\n")
        write(self.repo, ".git/config", "[core]\n")
        write(self.repo, "keep.py", "a = 1\n")
        data = radar.scan_codebase_health()
        self.assertEqual(data["total_files"], 1)
        self.assertEqual(data["file_type_counts"], {".py": 1})

    def test_file_toan_chu_thich_mat_do_bi_chan_tran_100(self):
        write(self.repo, "a.py", "# mot\n# hai\n\n")
        data = radar.scan_codebase_health()
        self.assertEqual(data["code_lines"], 0)
        self.assertEqual(data["code_comment_lines"], 2)
        # code_lines == 0 -> nhánh 100.0 cố định, KHÔNG chia cho 0
        self.assertEqual(data["signals"]["comment_density"], 100.0)

    def test_mat_do_chu_thich_chuan_hoa_theo_moc_15_phan_tram(self):
        write(self.repo, "a.py", "# c\n" + "x = 1\n" * 99)
        data = radar.scan_codebase_health()
        self.assertEqual((data["code_comment_lines"], data["code_lines"]), (1, 99))
        self.assertEqual(data["signals"]["comment_density"],
                         round(100.0 * (1 / 99) / 0.15, 1))

    def test_todo_nhieu_hon_10_dau_khong_xuong_duoi_0(self):
        write(self.repo, "a.py", "# TODO: x\n" * 11)
        data = radar.scan_codebase_health()
        self.assertEqual(len(data["todo_markers"]), 11)
        self.assertEqual(data["signals"]["todo_debt"], 0.0)


class TestParseSpecMarkdown(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.dir = self._tmp.name
        self.addCleanup(self._tmp.cleanup)

    def parse(self, name, text):
        path = write(self.dir, name, text)
        return compiler.parse_spec_markdown(path)

    def test_file_khong_ton_tai_tra_none(self):
        self.assertIsNone(compiler.parse_spec_markdown(
            os.path.join(self.dir, "khong-ton-tai.md")))

    def test_file_rong(self):
        parsed = self.parse("rong.md", "")
        self.assertEqual(parsed["title"], "rong.md")   # không có '# ' -> lấy basename
        self.assertEqual(parsed["metadata"], {})
        self.assertEqual(parsed["sections"], {})
        self.assertEqual(parsed["referenced_paths"], [])
        self.assertEqual(parsed["exempt_paths"], {})
        self.assertEqual(parsed["requirement_ids"], [])
        self.assertFalse(parsed["approved"])

    def test_bullet_truoc_moi_tieu_de_vao_muc_overview(self):
        parsed = self.parse("ov.md", "# T\n\n- mot\n* hai\n\n## Muc A\n\n- ba\n")
        self.assertEqual(parsed["sections"], {"Overview": ["mot", "hai"], "Muc A": ["ba"]})

    def test_bang_metadata_thieu_cot_thi_bo_qua_dong_do(self):
        parsed = self.parse("meta.md",
                            "# T\n\n| Thuộc tính | Giá trị |\n| :--- | :--- |\n"
                            "| State | Approved |\n| Người duyệt | An |\n")
        self.assertEqual(parsed["metadata"], {"State": "Approved", "Người duyệt": "An"})

    def test_khong_co_bang_metadata(self):
        parsed = self.parse("nometa.md", "# T\n\n| A | B |\n| :--- | :--- |\n| x | y |\n")
        self.assertEqual(parsed["metadata"], {})

    def test_touchpoints_loc_dung_thu_trong_duong_dan(self):
        body = (
            "# Spec\n\n"
            "## 3. Research current state\n\n"
            "- `scripts/khong-duoc-quet.sh`\n\n"
            "## 11. Architecture và code touchpoints\n\n"
            "- `scripts/beta.sh` và `docs/x.md`\n"
            "- `ten-file.py` nhưng `.sh` thì không\n"
            "- `https://vd.com/a.sh`, `/abs/x.sh`, `-flag`, `$VAR`, `@scope/pkg`\n"
            "- `co khoang trang.sh`\n"
            "- `thu-muc/`\n"
            "- `KHONG_PHAI_DUONG_DAN`\n\n"
            "## 12. Sau đó\n\n- `scripts/cung-khong-quet.sh`\n"
        )
        parsed = self.parse("tp.md", body)
        self.assertEqual(parsed["referenced_paths"],
                         ["docs/x.md", "scripts/beta.sh", "ten-file.py", "thu-muc"])

    def test_khong_co_muc_touchpoints(self):
        parsed = self.parse("notp.md", "# T\n\n## Khac\n\n- `scripts/beta.sh`\n")
        self.assertEqual(parsed["referenced_paths"], [])

    def test_mien_tru_phai_khai_ly_do_va_bi_tru_khoi_danh_sach(self):
        body = (
            "# T\n\n"
            "<!-- contract-exempt: scripts/go.sh — gỡ theo ADR-0004 -->\n"
            "<!-- contract-exempt: scripts/go2.sh -- ly do dung hai gach -->\n"
            "<!-- contract-exempt: scripts/khong-ly-do.sh -->\n\n"
            "## 11. Architecture và code touchpoints\n\n"
            "- `scripts/go.sh` `scripts/go2.sh` `scripts/khong-ly-do.sh` `scripts/o-lai.sh`\n"
        )
        parsed = self.parse("ex.md", body)
        self.assertEqual(parsed["exempt_paths"], {
            "scripts/go.sh": "gỡ theo ADR-0004",
            "scripts/go2.sh": "ly do dung hai gach",
        })
        self.assertEqual(parsed["referenced_paths"],
                         ["scripts/khong-ly-do.sh", "scripts/o-lai.sh"])

    def test_ma_yeu_cau_duy_nhat_va_sap_xep(self):
        parsed = self.parse("ids.md", "# T\n\nW-301 AC-2 FR-1 FR-1 NFR-10 XX-9\n")
        self.assertEqual(parsed["requirement_ids"], ["AC-2", "FR-1", "NFR-10", "W-301"])

    def test_approved_khong_phan_biet_hoa_thuong(self):
        self.assertTrue(self.parse("a1.md", "# T\n\napproved FOR implementation\n")["approved"])
        self.assertFalse(self.parse("a2.md", "# T\n\nchua duyet\n")["approved"])

    def test_spec_file_la_duong_dan_tuong_doi_theo_root_dir(self):
        path = write(self.dir, "rel.md", "# T\n")
        parsed = compiler.parse_spec_markdown(path)
        self.assertEqual(parsed["spec_file"],
                         os.path.relpath(path, compiler.ROOT_DIR))


if __name__ == "__main__":
    unittest.main(argv=[sys.argv[0]], verbosity=2)
PYEOF
