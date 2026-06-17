# 📋 App Store Connect 自动化配置指南

## 前置条件

- [ ] 已加入 Apple Developer Program ($99/年)
- [x] Git 仓库在 GitHub: `wolfsilence/cardlune`
- [x] Xcode 项目已配置 Team ID: `262TL285Q2`
- [x] 签名方式: Automatic

---

## 第 1 步: 创建 App Store Connect API Key

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入 **Users and Access** → **Integrations** 标签
3. 点击 **App Store Connect API** → **+** 创建新 Key
4. 填写:
   - **Name**: `GitHub Actions`
   - **Access**: `Developer`（必须包含 Developer 权限）
5. 下载 `.p8` 文件，**记下 `Key ID` 和 `Issuer ID`**

| 信息 | 说明 |
|------|------|
| Key ID | 创建 Key 时显示，如 `ABC123XYZ` |
| Issuer ID | 页面顶部，如 `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| .p8 文件内容 | 私钥，**只能下载一次** |

---

## 第 2 步: 配置 GitHub Secrets

进入仓库 **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

添加以下 3 个 Secrets:

| Secret 名称 | 值 |
|-------------|-----|
| `APP_STORE_CONNECT_KEY_ID` | 第 1 步的 Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | 第 1 步的 Issuer ID |
| `APP_STORE_CONNECT_API_KEY` | .p8 文件的**全部内容**（包含头部和脚注） |

```bash
# .p8 文件内容类似:
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdw...
-----END PRIVATE KEY-----
```

**务必完整复制，不要漏行。**

---

## 第 3 步: 在 App Store Connect 创建 App

1. 登录 App Store Connect → **My Apps** → **+**
2. **Bundle ID**: `com.Cardelune`
3. 完成基础信息填写（隐私政策、分类等）

> ⚠️ App Store Connect 中必须先存在 App 记录，否则上传会失败。

---

## 第 4 步: 推送代码触发部署

### 方式 A: 手动触发 (推荐)

1. GitHub → Actions → **🚀 Deploy to App Store Connect**
2. 点击 **Run workflow** → 选择是否提交审核 → **Run workflow**

### 方式 B: Tag 自动触发

```bash
git tag release-1.0.0
git push origin release-1.0.0
```

> Tag 触发默认只上传，不提审（安全策略）。

---

## 工作流说明

```
┌──────────────┐
│  1. Checkout  │
└──────┬───────┘
       ▼
┌──────────────┐
│  2. Archive   │  xcodebuild archive + 自动签名
└──────┬───────┘
       ▼
┌──────────────┐
│  3. Export    │  导出 App Store IPA
└──────┬───────┘
       ▼
┌──────────────┐
│  4. Upload    │  altool 上传到 App Store Connect
└──────┬───────┘
       ▼  (可选)
┌──────────────┐
│  5. Wait      │  轮询 build 处理状态 (最长 30 分钟)
└──────┬───────┘
       ▼
┌──────────────┐
│  6. Submit    │  App Store Connect API 提交审核
└──────────────┘
```

---

## 版本管理

| 配置 | 值 | 说明 |
|------|-----|------|
| `MARKETING_VERSION` | `1.0` | 用户看到的版本号 |
| `CURRENT_PROJECT_VERSION` | GitHub Run Number | 每次构建自动递增 |

修改版本号: 编辑 `project.pbxproj` 中的 `MARKETING_VERSION`。

---

## 常见问题

### 签名失败?
- 确认 Team ID 正确: `262TL285Q2`
- 确认 API Key 有 **Developer** 权限
- 确认 Bundle ID (`com.Cardelune`) 已在 Apple Developer Portal 注册

### Build 一直在 "Processing"?
- 正常处理需要 5-15 分钟
- 超过 30 分钟 → 检查 Apple 系统状态

### 提交审核失败?
- 确认 App Store Connect 中该版本已填写完所有必填信息
- 确认该版本没有已提交的审核
