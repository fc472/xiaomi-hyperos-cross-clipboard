# 小米 HyperOS 跨裝置剪貼簿

[English](README.md) | **繁體中文**

讓**陸版 HyperOS 手機／平板**和**非陸版 Windows 電腦**（安裝小米互联服务）之間，可以雙向互傳剪貼簿的**文字和截圖**。

完成後，手機、平板和電腦之間的文字和截圖都能雙向互傳，並且可以透過 **Gboard** 在各種 App 裡複製貼上。Windows 的地區設定**不用改**。

> 實測環境：小米 13 Pro（HyperOS 3 陸版）、Pad 6S Pro（陸版）、Windows 11 小米互联服务 **2.0.4.577**、milink 17.2.9.0。
> 其他輸入法需要另外調整模組才能支援。

---

## 無法互傳的原因

1. **電腦端只接受手機**：小米互联服务 2.0.4 起，電腦只接收「手機」傳來的剪貼簿。平板傳過來的文字和截圖會被直接丟掉，但反方向（電腦 → 平板）照樣可以傳。這就是為什麼常看到電腦 → 平板能傳，平板 → 電腦卻不行。
2. **手機／平板端的地區檢查**：陸版 milink 服務會拒絕和地區不同的電腦同步，由 `MiClipHook` 在裝置端略過這個檢查。
3. **版本會更新**：小米互联服务會自動更新，每次更新都會換掉被修補的檔案。腳本只支援 **2.0.4.577**，版本不對會自動停止，不會亂改，需要等針對新版的腳本。

---

## 需求

| 裝置 | 條件 |
|---|---|
| 手機／平板 | HyperOS 陸版、**需 root**（KernelSU / APatch / Magisk）、**LSPosed** |
| 電腦 | Windows 10/11、小米互联服务 **2.0.4.577**、系統管理員權限 |
| 網路 | 所有裝置在同一個允許裝置互相搜尋的區網（見[網路限制](#網路限制)） |

## 下載

請到 [**Releases**](../../releases/latest) 頁面下載：

| 檔案 | 用在 | 用途 |
|---|---|---|
| `Patch-DistClipboard.ps1` | 電腦 | 讓電腦接受平板傳來的剪貼簿 |
| `miclip_keep_v3.zip` | 手機／平板 | root 模組，守護「截圖寫入剪貼簿」設定 |
| `MiClipHook.apk` | 手機／平板 | LSPosed 模組：略過地區檢查、支援 Gboard 貼上、隱藏貼上提示視窗 |

使用前請比對 Release 說明裡列出的 SHA-256。

---

## 安裝步驟

### 步驟 1：電腦，修補小米互联服务（必須用系統管理員 PowerShell）

只用手機、沒有平板的話，這步可以跳過。

1. 以**系統管理員身分**開啟 Windows PowerShell。
2. 先 `cd` 到腳本存放的位置，例如：
   ```powershell
   cd C:\Users\<你的使用者名稱>\Downloads
   ```
3. 執行：
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Patch-DistClipboard.ps1
   ```
4. 看到綠字 `Installed: DC128FB5...` 就是成功了。

腳本做的事：
- 找到小米互联服务的安裝資料夾，確認版本是 2.0.4.577。
- 比對 `dist_clipboard.dll` 的 SHA-256 是否為原版，不符就中止。
- 把原檔備份成 `dist_clipboard.dll.orig`，修改 5 個 byte，再驗證結果；驗證失敗會自動還原原檔。

要還原的話執行：
```powershell
powershell -ExecutionPolicy Bypass -File .\Patch-DistClipboard.ps1 -Rollback
```

### 步驟 2：手機、平板，刷入 MiClip Keep 模組

用 KernelSU、APatch 或 Magisk 刷入 `miclip_keep_v3.zip`。之後每次開機都會自動開啟並守護「截圖寫入剪貼簿」（系統設定 `mi_screen_shots_write_clipboard_enable`）。

可在 root 管理器裡按模組的 **Action** 按鈕查看狀態，紀錄檔在 `/data/adb/miclip_keep.log`。

### 步驟 3：手機、平板，安裝 MiClipHook 並在 LSPosed 啟用

1. 安裝 `MiClipHook.apk`。
2. 打開 **LSPosed → 模組 → MiClipHook → 開啟模組**。
3. 作用域**兩個都要勾**（通常會自動勾選，仍請確認）：
   - `com.milink.service`（小米互聯服務）：略過地區檢查、Gboard 貼上、隱藏貼上提示視窗
   - `com.miui.securitycenter`（手機管家）：阻擋把「截圖寫入剪貼簿」關掉的寫入

如果之後清除過 root 環境或重刷 LSPosed，要重新啟用一次。

### 步驟 4：重新開機

手機、平板、電腦都要重新開機。

---

## 網路限制

公司、學校、宿舍這類 Wi-Fi，常會封鎖裝置之間的互相搜尋（mDNS／多播），或開啟用戶端隔離（AP isolation）。常見的狀況是：

- 電腦 App 上看不到裝置，或一直顯示未連接 → 文字和截圖都傳不了
- 有時候能連上、文字也傳得過去，但**截圖傳不了**，因為圖片要另外透過 Wi-Fi 資料通道傳送，這個通道會被擋下來

遇到這種情況，請改由電腦或手機開熱點，讓其他裝置都連過去，就能互傳了（兩種方式都已實測）。如果用 Windows 行動熱點，它預設在沒有裝置連線時會自動關閉，重開機後要記得確認熱點是開的。

## 小米互联服务更新後

如果平板 → 電腦又不通，先看小米互联服务的版本是不是已經不是 2.0.4.577。手機 ↔ 電腦不受這個修補影響。

---

## Repo 結構

```
pc/Patch-DistClipboard.ps1     電腦端修補腳本（含 -Rollback）
module/miclip_keep/            MiClip Keep root 模組原始檔
```

Releases 裡的模組 zip 由 `module/miclip_keep/` 打包而成（壓縮資料夾「內容」，`META-INF` 要在 zip 最上層）。

## 免責聲明

- 本專案**與小米無關**，也不散布任何小米的檔案；電腦端腳本只修改你自己電腦上已安裝的那一份。
- 修改系統元件和使用 root 有風險，使用者需自行承擔。

## 授權

[MIT](LICENSE)
