# การรันเทสและ Code coverage

โปรเจกต์ใช้ **Minitest** (ค่าเริ่มต้นของ Rails) ในโฟลเดอร์ `test/` และมี **RSpec** ใน `spec/` เป็นทางเลือก

รายงาน coverage สร้างด้วย **SimpleCov** ไฟล์หลักอยู่ที่ `config/simplecov_bootstrap.rb` (โหลดก่อน Rails จาก `test/test_helper.rb` และ `spec/simplecov_setup.rb`)

---

## Minitest

### รันเทสทั้งหมด

```bash
bin/rails test
```

### รันเฉพาะไฟล์หรือโฟลเดอร์

```bash
bin/rails test test/models/user_test.rb
bin/rails test test/controllers/
```

เทสคอนโทรลเลอร์เป็น **Integration tests** (`ActionDispatch::IntegrationTest`) เรียก HTTP จริงผ่าน route ใช้ `sign_in` จาก `Devise::Test::IntegrationHelpers` (รวมใน `test/test_helper.rb` แล้ว) ตัวช่วยสร้างข้อมูลเทสใช้ `ModelTestHelpers` เช่น `create_user!`, `active_store_and_product`

### รันแล้วเปิดรายงาน coverage ในเบราว์เซอร์ (เครื่อง local เท่านั้น)

```bash
bin/test
```

สคริปต์ `bin/test` จะเรียก `bin/rails test` ตามปกติ จากนั้นถ้าไม่ได้อยู่ใน CI และมีไฟล์ `coverage/index.html` จะเปิดด้วย `open` (macOS) หรือ `xdg-open` (Linux)

ส่งอาร์กิวเมนต์ต่อได้เหมือน `rails test`:

```bash
bin/test test/models/application_record_test.rb
```

### ปิดการวัด coverage (รันเร็วขึ้น)

```bash
COVERAGE=false bin/rails test
```

ค่าเริ่มต้นใช้ **1 worker** (ลดปัญหา fork + PostgreSQL) ถ้า `COVERAGE=false` จะรัน parallel ได้โดยตั้ง `PARALLEL_WORKERS=4` หรือ `PARALLEL_WORKERS=max` (ใช้จำนวน CPU)

### เปิด branch coverage (ช้ากว่า)

```bash
COVERAGE_BRANCH=1 bin/rails test
```

### ฐานข้อมูลเทส

ก่อนรันครั้งแรกหรือหลัง migration:

```bash
bin/rails db:test:prepare
```

---

## RSpec

ยังใช้ SimpleCov ชุดเดียวกับ Minitest ผ่าน `spec/simplecov_setup.rb`

```bash
bundle exec rspec
```

ปิด coverage:

```bash
COVERAGE=false bundle exec rspec
```

---

## ตำแหน่งรายงาน coverage

หลังรันเทส (เมื่อไม่ได้ตั้ง `COVERAGE=false`) จะได้โฟลเดอร์:

| ไฟล์ | คำอธิบาย |
|------|----------|
| `coverage/index.html` | รายงานแบบเปิดในเบราว์เซอร์ |

โฟลเดอร์ `coverage/` อยู่ใน `.gitignore` ไม่ commit ขึ้น repo

---

## ตัวแปรสภาพแวดล้อมที่เกี่ยวกับ coverage

| ตัวแปร | ความหมาย |
|--------|----------|
| `COVERAGE=false` | ไม่โหลด SimpleCov |
| `COVERAGE_BRANCH=1` | วัด branch coverage (ใช้เวลานานขึ้น) |
| `SIMPLECOV_COMMAND_NAME` | กำหนดชื่อชุดผลในรายงาน (ข้ามการเดาอัตโนมัติ) |
| `CI=true` | ใน CI ไม่ควรพึ่งการเปิดเบราว์เซอร์; `bin/test` จะไม่รัน `open`/`xdg-open` |

---

## พฤติกรรมกับ parallel tests (Minitest)

เมื่อ **เปิด** coverage (`COVERAGE` ไม่ใช่ `false`) จะตั้ง `parallelize` เป็น **1 worker** เพื่อไม่ให้ผล SimpleCov แตกหลายโปรเซส

เมื่อ **ปิด** coverage จะใช้ parallel ตาม CPU ตามเดิม (ดู `test/test_helper.rb`)

---

## CI (GitHub Actions)

ใน workflow จะรัน `bin/rails db:test:prepare && bin/rails test` และอัปโหลดโฟลเดอร์ `coverage/` เป็น artifact ชื่อ `coverage` (ถ้ามีไฟล์)

---

## รันเช็คแบบเดียวกับ pipeline หลายขั้น (local)

```bash
bin/ci
```

รายละเอียดขั้นตอนอยู่ใน `config/ci.rb`

---

## ไฟล์อ้างอิง

| ไฟล์ | บทบาท |
|------|--------|
| `config/simplecov_bootstrap.rb` | ตั้งค่า SimpleCov กลาง |
| `test/test_helper.rb` | โหลด SimpleCov แล้วค่อย boot Rails |
| `spec/simplecov_setup.rb` | โหลด SimpleCov สำหรับ RSpec |
| `spec/spec_helper.rb` | `require_relative "simplecov_setup"` บรรทัดแรก |
| `bin/test` | Minitest + เปิด `coverage/index.html` เมื่อไม่ใช่ CI |
