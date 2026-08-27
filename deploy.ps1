# ============================================================
# Alan 个人作品集 · 一键发布脚本
# 作用：提交本次修改 → 推送到 GitHub → 等待自动部署 → 验证上线
# 用法（在项目根目录执行）：
#   powershell -ExecutionPolicy Bypass -File deploy.ps1
#   powershell -ExecutionPolicy Bypass -File deploy.ps1 -Message "更新了项目描述"
# ============================================================
param(
    [string]$Message = ""
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$Repo       = "Alan-0123/alan-0123.github.io"
$Branch     = "main"
$LiveUrl    = "https://alan-0123.github.io/"
$ActionsUrl = "https://github.com/$Repo/actions"
$ApiRuns    = "https://api.github.com/repos/$Repo/actions/runs?per_page=1"

function Write-Step { param($Text) Write-Host "" ; Write-Host "==> $Text" -ForegroundColor Cyan }
function Write-Ok   { param($Text) Write-Host "    $Text" -ForegroundColor Green }
function Write-Warn { param($Text) Write-Host "    $Text" -ForegroundColor Yellow }

function Get-LatestRunId {
    try {
        $run = (Invoke-RestMethod -Uri $ApiRuns -Headers @{ "User-Agent" = "portfolio-deploy" }).workflow_runs | Select-Object -First 1
        if ($run) { return [long]$run.id } else { return 0 }
    } catch {
        return -1
    }
}

# ---------- 1. 检查是否有修改 ----------
Write-Step "检查本地修改…"
$changes = git status --porcelain
if (-not $changes) {
    Write-Warn "没有需要发布的修改，网站保持最新状态。"
    exit 0
}
$changeCount = ($changes | Measure-Object).Count
Write-Ok "发现 $changeCount 处修改："
$changes | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }

# 记录推送前的最新一次部署编号，稍后用来识别新触发的部署
$prevRunId = Get-LatestRunId

# ---------- 2. 提交 ----------
if (-not $Message) {
    $Message = "更新站点内容 {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm")
}
Write-Step "提交修改（$Message）"
git add -A
git commit -m $Message
if ($LASTEXITCODE -ne 0) { Write-Host "提交失败，请检查上方 git 输出。" -ForegroundColor Red; exit 1 }
Write-Ok "提交完成。"

# ---------- 3. 推送 ----------
Write-Step "推送到 GitHub（$Branch 分支）…"
git push origin $Branch
if ($LASTEXITCODE -ne 0) { Write-Host "推送失败，请检查网络或凭据后重试。" -ForegroundColor Red; exit 1 }
Write-Ok "推送完成，已触发自动部署。"

# ---------- 4. 等待 GitHub Actions 部署 ----------
Write-Step "等待部署完成（约 1 分钟）…"
$maxWaitSeconds = 180
$waited = 0
$conclusion = $null

while ($waited -lt $maxWaitSeconds) {
    Start-Sleep -Seconds 6
    $waited += 6
    try {
        $run = (Invoke-RestMethod -Uri $ApiRuns -Headers @{ "User-Agent" = "portfolio-deploy" }).workflow_runs | Select-Object -First 1
        if ($run -and [long]$run.id -ne $prevRunId -and $run.status -eq "completed") {
            $conclusion = $run.conclusion
            break
        }
        Write-Host "    部署中…已等待 $waited 秒" -ForegroundColor DarkGray
    } catch {
        Write-Warn "查询部署状态暂时失败，继续等待…"
    }
}

if ($conclusion -eq "success") {
    Write-Ok "部署成功！"
} elseif ($conclusion) {
    Write-Host "    部署结束，结果：$conclusion。详见 $ActionsUrl" -ForegroundColor Red
    exit 1
} else {
    Write-Warn "等待超时（$maxWaitSeconds 秒），部署可能仍在进行，可稍后访问 $ActionsUrl 查看。"
}

# ---------- 5. 验证线上可访问 ----------
Write-Step "验证线上站点…"
try {
    $resp = Invoke-WebRequest -Uri $LiveUrl -UseBasicParsing
    if ($resp.StatusCode -eq 200) {
        Write-Ok "站点已上线：$LiveUrl"
    } else {
        Write-Warn "站点返回 HTTP $($resp.StatusCode)，请稍后刷新重试。"
    }
} catch {
    Write-Warn "暂时无法访问站点（CDN 同步可能需要几十秒），请稍后刷新 $LiveUrl"
}

Write-Host ""
Write-Host "发布流程结束。" -ForegroundColor Cyan
