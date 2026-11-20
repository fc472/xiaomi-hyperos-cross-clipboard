# 小米陸版ROM 手機、平板與電腦跨裝置剪貼簿

[English](README.md) | **繁體中文**

讓陸版 HyperOS 手機、平板和非陸版 Windows 電腦（小米互联服务）之間，可以雙向互傳剪貼簿的文字和截圖，並且可以透過 Gboard 在各種 App 裡貼上。Windows 的地區設定不用改。

## 實測

* 小米 13 Pro 陸版（HyperOS 3）
* 小米平板 6S Pro 陸版
* Windows 11，小米互联服务 2.0.4.577，milink 17.2.9.0

## 需求

* 手機、平板：已 root（KernelSU、APatch、Magisk 皆可）、已安裝 LSPosed
* 電腦：Windows 10/11、小米互联服务 2.0.4.577、系統管理員權限
* 所有裝置在同一個網路下（見附註）

## 下載

到 [Releases](../../releases/latest) 下載以下三個檔案，使用前請比對 Release 說明中的 SHA-256：

* `Patch-DistClipboard.ps1`：電腦用，讓電腦接受平板傳來的剪貼簿
* `miclip_keep_v3.zip`：手機、平板用的 root 模組，保持「截圖寫入剪貼簿」開啟
* `MiClipHook.apk`：手機、平板用的 LSPosed 模組，略過地區檢查、支援 Gboard 貼上

## 安裝

**1. 電腦：修補小米互联服务**

只用手機、沒有平板的話可以跳過。以系統管理員身分開啟 PowerShell，`cd` 到腳本所在的資料夾後執行：

```powershell
powershell -ExecutionPolicy Bypass -File .\Patch-DistClipboard.ps1
```

看到綠字 `Installed: DC128FB5...` 就是成功。要還原的話，在最後加上 `-Rollback` 再執行一次。

**2. 手機、平板：刷入 MiClip Keep 模組**

用 KernelSU、APatch 或 Magisk 刷入 `miclip_keep_v3.zip`。

**3. 手機、平板：在 LSPosed 啟用 MiClipHook**

安裝 `MiClipHook.apk`，打開 LSPosed → 模組 → MiClipHook → 開啟模組，作用域勾選「小米互聯服務（com.milink.service）」和「手機管家（com.miui.securitycenter）」兩個。

**4. 重新開機**

手機、平板、電腦都要重新開機。

附註：公司、學校、宿舍的 Wi-Fi 常會擋掉裝置互相搜尋，會出現連不上，或文字能傳但截圖傳不了。改用電腦或手機開熱點，讓其他裝置連過去即可。

小米互联服务自動更新後，平板 → 電腦可能又會不通，因為腳本只支援 2.0.4.577 版，需要等新版的腳本。手機 ↔ 電腦不受影響。

## 其他

* `pc/` 是電腦端腳本，`module/miclip_keep/` 是 root 模組原始檔。
* 本專案與小米無關，不散布任何小米的檔案，腳本只修改你電腦上已安裝的那一份。
* 授權：[MIT](LICENSE)。修改系統元件和使用 root 有風險，使用者需自行承擔。
