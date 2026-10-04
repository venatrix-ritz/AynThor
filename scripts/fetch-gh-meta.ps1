# Primary-source GitHub metadata (releases, issues, PRs) for armada-os/armada -> refs/_gh/ (gitignored).
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$out = Join-Path $root 'refs/_gh'
New-Item -ItemType Directory -Force -Path $out | Out-Null
$repo = 'armada-os/armada'

gh release list --repo $repo --limit 200 --json tagName,name,isPrerelease,isDraft,publishedAt,createdAt | Set-Content "$out/releases-list.json" -Encoding utf8
$tags = (Get-Content "$out/releases-list.json" -Raw | ConvertFrom-Json).tagName
New-Item -ItemType Directory -Force -Path "$out/releases" | Out-Null
foreach ($t in $tags) {
  gh release view $t --repo $repo --json tagName,name,isPrerelease,publishedAt,body,url,assets | Set-Content "$out/releases/$t.json" -Encoding utf8
}
gh issue list --repo $repo --state all --limit 2000 --json number,title,state,labels,createdAt,closedAt,author,body,comments,url | Set-Content "$out/issues.json" -Encoding utf8
gh pr list --repo $repo --state all --limit 2000 --json number,title,state,labels,createdAt,mergedAt,author,body,headRefName,baseRefName,url | Set-Content "$out/prs.json" -Encoding utf8
gh api "repos/$repo/tags" --paginate | Set-Content "$out/tags.json" -Encoding utf8
gh api "repos/$repo/branches" --paginate --jq '[.[] | {name, sha: .commit.sha}]' | Set-Content "$out/branches.json" -Encoding utf8
gh api "repos/$repo/contributors" --paginate --jq '[.[] | {login, contributions}]' | Set-Content "$out/contributors.json" -Encoding utf8
gh api "repos/$repo" | Set-Content "$out/repo.json" -Encoding utf8
Write-Host "done"
