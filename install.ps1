# --- PowerShell �ű����� ---
# $ErrorActionPreference = "Stop"����������������ֹ����ʱ������ֹͣ�ű�ִ�С�
# $ProgressPreference = "SilentlyContinue"������ Invoke-WebRequest �� Cmdlet �Ľ�������ʾ��
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# --- ��ɫ���� (������ PowerShell) ---
# ��Щ����ʹ�� Write-Host Cmdlet �� -ForegroundColor �������������ɫ���ı���
# ע�⣺��Щ��ɫ���ִ��� Windows Terminal �� PowerShell 7+ ��֧�����ã����ھɰ����̨�п�����ʾ����ȷ��
Function Write-Host-Green { param([string]$Message) Write-Host -ForegroundColor Green $Message }
Function Write-Host-Blue { param([string]$Message) Write-Host -ForegroundColor Blue $Message }
Function Write-Host-Yellow { param([string]$Message) Write-Host -ForegroundColor Yellow $Message }
Function Write-Host-Red { param([string]$Message) Write-Host -ForegroundColor Red $Message }
Function Write-Host-Purple { param([string]$Message) Write-Host -ForegroundColor DarkMagenta $Message } # PowerShell �е���ɫͨ���� DarkMagenta
Function Write-Host-Cyan { param([string]$Message) Write-Host -ForegroundColor Cyan $Message }

# --- ���ò��� ---
$LADEFREE_REPO_URL_BASE = "https://github.com/amosgansweet/ladefree" # Ladefree Ӧ�õ� GitHub �ֿ����URL
$LADEFREE_REPO_BRANCH = "main" # Ladefree �ֿ�ķ�֧
$LADE_CLI_NAME = "lade.exe" # Lade CLI ��ִ���ļ��� (Windows ��ͨ���� .exe)
# $env:ProgramFiles �� Windows �ϵı�׼�����ļ�Ŀ¼������ C:\Program Files
$LADE_INSTALL_PATH = "$env:ProgramFiles\LadeCLI" # Lade CLI �ı�׼��װ·��

# --- ������Ϣ ---
# ���ߣ�Joey
# ���ͣ�joeyblog.net
# Telegram Ⱥ��https://t.me/+ft-zI76oovgwNmRh

# --- ������������ʾ��ӭ��Ϣ ---
Function Display-Welcome {
    Clear-Host # �������̨��Ļ
    Write-Host-Cyan "#############################################################"
    Write-Host-Cyan "#                                                           #"
    Write-Host-Cyan "#        " -NoNewline; Write-Host-Blue "��ӭʹ�� Lade CLI �๦�ܹ����ű� v1.0.0" -NoNewline; Write-Host-Cyan "        #"
    Write-Host-Cyan "#                                                           #"
    Write-Host-Cyan "#############################################################"
    Write-Host-Green ""
    Write-Host "  >> ����: Joey"
    Write-Host "  >> ����: joeyblog.net"
    Write-Host "  >> Telegram Ⱥ: https://t.me/+ft-zI76oovgwNmRh"
    Write-Host "  >> ����Ĵ���note.js���� https://github.com/eooce ���� "
    Write-Host ""
    Write-Host-Yellow "����һ���Զ��� Lade Ӧ�ò���͹������ߣ�ּ�ڼ򻯲�����"
    Write-Host ""
    Read-Host "�� Enter ����ʼ..." | Out-Null # �ȴ��û��� Enter ��������������
}

# --- ������������ʾ���������� ---
Function Display-SectionHeader {
    param([string]$Title) # ����һ���ַ���������Ϊ����
    Write-Host ""
    Write-Host-Purple "--- $Title ---"
    Write-Host-Purple "-----------------------------------"
}

# --- ������������������Ƿ���� ---
Function Test-CommandExists {
    param([string]$Command) # ����һ���ַ���������Ϊ������
    # Get-Command ���Բ���ָ�������-ErrorAction SilentlyContinue ���ƴ�����Ϣ��
    # ����ҵ������������һ�����󣬷��򷵻� $null��
    (Get-Command -Name $Command -ErrorAction SilentlyContinue) -ne $null
}

# --- ������������� Lade CLI �Ƿ�����ҿ��� ---
Function Test-LadeCli {
    Test-CommandExists $LADE_CLI_NAME # ���� Test-CommandExists ��� Lade CLI
}

# --- ����������ȷ���ѵ�¼ Lade ---
Function Ensure-LadeLogin {
    Write-Host ""
    Write-Host-Purple "--- ��� Lade ��¼״̬ ---"
    # ����ִ��һ����Ҫ��֤�� Lade ������� `lade apps list`����
    # ���������ʧ�ܣ��׳����󣩣����ʾδ��¼��Ự���ڡ�
    try {
        # ʹ�� & �����ִ���ⲿ��ִ���ļ���Out-Null ��������ı�׼�����
        & lade apps list 
        Write-Host-Green "Lade �ѵ�¼��"
    } catch {
        Write-Host-Yellow "Lade ��¼�Ự�ѹ��ڻ�δ��¼���������ʾ�������� Lade ��¼ƾ�ݡ�"
        try {
            & lade login # ��ʾ�û����е�¼
            Write-Host-Green "Lade ��¼�ɹ���"
        } catch {
            Write-Host-Red "����Lade ��¼ʧ�ܡ������û���/������������ӡ�"
            exit 1 # ��¼ʧ�ܣ��˳��ű�
        }
    }
}

# --- ���ܺ���������Ӧ�� ---
Function Deploy-App {
    Display-SectionHeader "���� Lade Ӧ��"

    Ensure-LadeLogin # ȷ���û��ѵ�¼

    $LADE_APP_NAME = Read-Host "��������Ҫ����� Lade Ӧ������ (����: my-ladefree-app):"
    # [string]::IsNullOrWhiteSpace ����ַ����Ƿ�Ϊ null���ջ�������հ��ַ�
    if ([string]::IsNullOrWhiteSpace($LADE_APP_NAME)) {
        Write-Host-Yellow "Ӧ�����Ʋ���Ϊ�ա�ȡ������"
        return # ���غ�����������ִ�в���
    }

    Write-Host "���ڼ��Ӧ�� '$LADE_APP_NAME' �Ƿ����..."
    $app_exists = $false
    try {
        $appList = & lade apps list # ��ȡӦ���б�
        # -like ���������ͨ���ƥ�䡣����б����Ƿ����Ӧ�����ơ�
        if ($appList -like "*$LADE_APP_NAME*") {
            $app_exists = $true
        }
    } catch {
        # �����ȡӦ���б�ʧ�ܣ���������������� Lade CLI ���⣬�������Գ��Լ�����
        Write-Host-Yellow "�޷���ȡӦ���б�����֤���Ƿ���ڣ��ٶ������ڻ��������/����"
    }

    if ($app_exists) {
        Write-Host-Green "Ӧ�� '$LADE_APP_NAME' �Ѵ��ڣ���ֱ�Ӳ�����¡�"
    } else {
        Write-Host-Yellow "Ӧ�� '$LADE_APP_NAME' �����ڣ������Դ�����Ӧ�á�"
        Write-Host-Cyan "ע�⣺����Ӧ�ý�����ʽѯ�� 'Plan' �� 'Region'�����ֶ�ѡ��"
        try {
            & lade apps create "$LADE_APP_NAME" # ���Դ���Ӧ��
            Write-Host-Green "Lade Ӧ�ô��������ѷ��͡�"
        } catch {
            Write-Host-Red "����Lade Ӧ�ô���ʧ�ܡ����������Ӧ�������Ƿ���á�"
            return # ����ʧ�ܣ����غ���
        }
    }

    Write-Host ""
    Write-Host-Blue "--- �������� ZIP ������ Ladefree Ӧ�� (������ Git) ---"
    # Join-Path Cmdlet ��ȫ��ƴ��·����������ͬ��·���ָ�����
    $ladefree_temp_download_dir = Join-Path $env:TEMP "ladefree_repo_download_$(Get-Random)"
    # New-Item -ItemType Directory -Force ����Ŀ¼����������򲻱�����Out-Null ���������
    New-Item -ItemType Directory -Force -Path $ladefree_temp_download_dir | Out-Null

    $ladefree_download_url = "$LADEFREE_REPO_URL_BASE/archive/refs/heads/$LADEFREE_REPO_BRANCH.zip"
    $temp_ladefree_archive = Join-Path $ladefree_temp_download_dir "ladefree.zip"

    Write-Host "�������� $LADEFREE_REPO_URL_BASE ($LADEFREE_REPO_BRANCH ��֧) Ϊ ZIP ��..."
    Write-Host "���� URL: $ladefree_download_url"

    try {
        # Invoke-WebRequest �� PowerShell �����ļ�����ҳ���ݵ���Ҫ Cmdlet��
        Invoke-WebRequest -Uri $ladefree_download_url -OutFile $temp_ladefree_archive
    } catch {
        Write-Host-Red "�������� Ladefree �ֿ� ZIP ��ʧ�ܡ����� URL ���������ӡ�"
        # Remove-Item -Recurse -Force ǿ��ɾ��Ŀ¼�������ݣ�-ErrorAction SilentlyContinue ����ɾ������
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return # ����ʧ�ܣ����غ���
    }

    Write-Host "������ɣ����ڽ�ѹ..."
    try {
        # Expand-Archive �� PowerShell ��ѹ ZIP �ļ��� Cmdlet��
        Expand-Archive -Path $temp_ladefree_archive -DestinationPath $ladefree_temp_download_dir -Force
    } catch {
        Write-Host-Red "���󣺽�ѹ Ladefree ZIP ��ʧ�ܡ���ȷ�� 'Expand-Archive' ���ܿ��ã�PowerShell 5.0+ ���ã���"
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return # ��ѹʧ�ܣ����غ���
    }

    # ���ҽ�ѹ���Ӧ�ó���Ŀ¼ (���磬ladefree-main)��
    # Get-ChildItem -Directory ����ȡĿ¼��-Filter "ladefree-*" �����ƹ��ˡ�
    # Select-Object -ExpandProperty FullName ��ѡ������·����
    # Select-Object -First 1 ȷ��ֻȡ��һ��ƥ���
    $extracted_app_path = Get-ChildItem -Path $ladefree_temp_download_dir -Directory -Filter "ladefree-*" | Select-Object -ExpandProperty FullName | Select-Object -First 1

    if ([string]::IsNullOrWhiteSpace($extracted_app_path)) {
        Write-Host-Red "����δ����ʱ����Ŀ¼���ҵ���ѹ��� Ladefree Ӧ�ó���Ŀ¼��"
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return # δ�ҵ�Ŀ¼�����غ���
    }

    Write-Host-Blue "���ڴӱ��ؽ�ѹ·�� $extracted_app_path ���� Lade��$LADE_APP_NAME ..."
    Push-Location $extracted_app_path # ���ĵ�ǰ����Ŀ¼����ѹ·��
    try {
        & lade deploy --app "$LADE_APP_NAME" # ִ�в�������
        $deploy_status = $LASTEXITCODE # ��ȡ�ⲿ������˳�����
    } catch {
        Write-Host-Red "����Lade Ӧ�ò���ʧ�ܡ����� Ladefree ���뱾��������� Lade ƽ̨��־��"
        Pop-Location # �ָ���֮ǰ��Ŀ¼
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return # ����ʧ�ܣ����غ���
    }
    Pop-Location # �ָ���֮ǰ��Ŀ¼

    Write-Host "������ʱ����Ŀ¼ $ladefree_temp_download_dir..."
    Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue

    if ($deploy_status -ne 0) {
        Write-Host-Red "����Lade Ӧ�ò���ʧ�ܡ����� Ladefree ��������� Lade ƽ̨��־��"
        return # ����ʧ�ܣ����غ���
    }
    Write-Host-Green "Lade Ӧ�ò���ɹ���"

    Write-Host ""
    Write-Host-Cyan "--- ������� ---"
}

# --- ���ܺ������鿴����Ӧ�� ---
Function View-Apps {
    Display-SectionHeader "�鿴���� Lade Ӧ��"

    Ensure-LadeLogin # ȷ���û��ѵ�¼

    try {
        & lade apps list # ִ�в鿴Ӧ���б�����
    } catch {
        Write-Host-Red "�����޷���ȡӦ���б������������ Lade CLI ״̬��"
    }
}

# --- ���ܺ�����ɾ��Ӧ�� ---
Function Delete-App {
    Display-SectionHeader "ɾ�� Lade Ӧ��"

    Ensure-LadeLogin # ȷ���û��ѵ�¼

    $APP_TO_DELETE = Read-Host "��������Ҫɾ���� Lade Ӧ������:"
    if ([string]::IsNullOrWhiteSpace($APP_TO_DELETE)) {
        Write-Host-Yellow "Ӧ�����Ʋ���Ϊ�ա�ȡ��ɾ����"
        return
    }

    Write-Host-Red "���棺������ɾ��Ӧ�� '$APP_TO_DELETE'���˲������ɳ�����"
    $CONFIRM_DELETE = Read-Host "ȷ��Ҫɾ���� (y/N):"
    $CONFIRM_DELETE = $CONFIRM_DELETE.ToLower() # ������ת��ΪСд

    if ($CONFIRM_DELETE -eq "y") {
        try {
            & lade apps remove "$APP_TO_DELETE" # �� 'delete' ����Ϊ 'remove'
            Write-Host-Green "Ӧ�� '$APP_TO_DELETE' �ѳɹ�ɾ����"
        } catch {
            Write-Host-Red "����ɾ��Ӧ�� '$APP_TO_DELETE' ʧ�ܡ�����Ӧ�������Ƿ���ȷ�����Ƿ���Ȩ�ޡ�"
        }
    } else {
        Write-Host-Yellow "ȡ��ɾ��������"
    }
}

# --- ���ܺ������鿴Ӧ����־ ---
Function View-AppLogs {
    Display-SectionHeader "�鿴 Lade Ӧ����־"

    Ensure-LadeLogin # ȷ���û��ѵ�¼

    $APP_FOR_LOGS = Read-Host "��������Ҫ�鿴��־�� Lade Ӧ������:"
    if ([string]::IsNullOrWhiteSpace($APP_FOR_LOGS)) {
        Write-Host-Yellow "Ӧ�����Ʋ���Ϊ�ա�ȡ���鿴��־��"
        return
    }

    Write-Host-Cyan "���ڲ鿴Ӧ�� '$APP_FOR_LOGS' ��ʵʱ��־ (�� Ctrl+C ֹͣ)..."
    try {
        # lade logs �� -f ��־ͨ����ʾ�����桱��־���
        & lade logs -a "$APP_FOR_LOGS" -f
    } catch {
        Write-Host-Red "�����޷���ȡӦ�� '$APP_FOR_LOGS' ����־������Ӧ�������Ƿ���ȷ��Ӧ���Ƿ��������С�"
    }
}

# --- ��ʼ������ (ȷ�� Lade CLI �Ѱ�װ) ---
Function Install-LadeCli {
    Display-SectionHeader "����װ Lade CLI"

    if (Test-LadeCli) {
        Write-Host-Green "Lade CLI �Ѱ�װ��$(Get-Command $LADE_CLI_NAME).Path"
        return $true # Lade CLI �Ѿ����ڣ����� true
    }

    Write-Host-Yellow "Lade CLI δ��װ�����ڳ����Զ���װ Lade CLI..."

    $lade_release_url = "https://github.com/lade-io/lade/releases"
    $lade_temp_dir = Join-Path $env:TEMP "lade_cli_download_temp_$(Get-Random)"
    New-Item -ItemType Directory -Force -Path $lade_temp_dir | Out-Null

    $os_type = "windows" # �� Windows ��Ӳ����Ϊ "windows"
    # Get-WmiObject Win32_Processor ��ȡ��������Ϣ��Architecture ���Ա�ʾ�ܹ����͡�
    $arch_type = (Get-WmiObject Win32_Processor).Architecture

    $arch_suffix = ""
    # ���ݴ������ܹ����������ļ�����׺
    switch ($arch_type) {
        0 { $arch_suffix = "-amd64" } # x86 �ܹ�
        9 { $arch_suffix = "-amd64" } # x64 �ܹ�
        6 { $arch_suffix = "-arm64" } # ARM64 �ܹ�
        default {
            Write-Host-Red "���󣺲�֧�ֵ� Windows �ܹ���$arch_type"
            Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
            exit 1
        }
    }
    Write-Host-Blue "��⵽ Windows ($((Get-WmiObject Win32_Processor).Caption)) �ܹ���"

    # ����Ҫ�Ĺ��ߣ�Invoke-WebRequest (PowerShell ����) �� curl.exe (����û���װ��)
    if (-not (Test-CommandExists "curl.exe") -and -not (Test-CommandExists "Invoke-WebRequest")) {
        Write-Host-Red "����δ�ҵ� 'curl.exe' �� 'Invoke-WebRequest' (PowerShell ������ͻ���)����ȷ�� PowerShell �Ѹ��»� curl �Ѱ�װ��"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }
    # ��� Expand-Archive (PowerShell ����)
    if (-not (Test-CommandExists "Expand-Archive")) {
        Write-Host-Red "����δ�ҵ� 'Expand-Archive' (PowerShell �Ľ�ѹ����)����ȷ�� PowerShell 5.0+ �Ѱ�װ��"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    Write-Host "���ڻ�ȡ���°汾�� Lade CLI..."
    try {
        # Invoke-RestMethod ���ڵ��� RESTful Web ���񣬻�ȡ GitHub API �� JSON ��Ӧ��
        $latest_release_info = Invoke-RestMethod -Uri "https://api.github.com/repos/lade-io/lade/releases/latest"
        $latest_release_tag = $latest_release_info.tag_name # �� JSON ��Ӧ����ȡ tag_name
    } catch {
        Write-Host-Red "�����޷���ȡ���°汾�� Lade CLI����������� GitHub API ���ơ�"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    if ([string]::IsNullOrWhiteSpace($latest_release_tag)) {
        Write-Host-Red "�����޷�ȷ������ Lade CLI �汾��"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }
    $lade_version = $latest_release_tag
    Write-Host-Green "��⵽���°汾��$lade_version"

    $filename_to_download = "lade-${os_type}${arch_suffix}.zip" # Lade CLI for Windows ͨ���� .zip
    $download_url = "$lade_release_url/download/$lade_version/$filename_to_download"
    $temp_archive = Join-Path $lade_temp_dir $filename_to_download

    Write-Host "���� URL: $download_url"
    Write-Host "�������� $filename_to_download �� $temp_archive..."
    try {
        Invoke-WebRequest -Uri $download_url -OutFile $temp_archive # �����ļ�
    } catch {
        Write-Host-Red "�������� Lade CLI ʧ�ܡ������������ӻ� URL �Ƿ���ȷ��"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    Write-Host "������ɣ����ڽ�ѹ..."
    try {
        Expand-Archive -Path $temp_archive -DestinationPath $lade_temp_dir -Force # ��ѹ ZIP �ļ�
    } catch {
        Write-Host-Red "���󣺽�ѹ ZIP �ļ�ʧ�ܡ���ȷ�� 'Expand-Archive' Cmdlet ���� (PowerShell 5.0+)��"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # �ڽ�ѹ���Ŀ¼�в��� Lade CLI ��ִ���ļ���
    # -Recurse �ݹ�������Ŀ¼��-File �������ļ���-Filter �����ļ�����
    $extracted_lade_path = Get-ChildItem -Path $lade_temp_dir -Recurse -File -Filter $LADE_CLI_NAME | Select-Object -ExpandProperty FullName | Select-Object -First 1

    if ([string]::IsNullOrWhiteSpace($extracted_lade_path)) {
        Write-Host-Red "�����ڽ�ѹ�����ʱĿ¼��δ�ҵ� '$LADE_CLI_NAME' ��ִ���ļ�������ѹ�������ݡ�"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # ȷ��Ŀ�갲װ·������
    if (-not (Test-Path $LADE_INSTALL_PATH)) {
        New-Item -ItemType Directory -Force -Path $LADE_INSTALL_PATH | Out-Null
    }

    Write-Host "���ڽ� Lade CLI �ƶ��� $LADE_INSTALL_PATH..."
    try {
        # Move-Item �ƶ��ļ���-Force ǿ�Ƹ���Ŀ�꣨������ڣ���
        Move-Item -Path $extracted_lade_path -Destination (Join-Path $LADE_INSTALL_PATH $LADE_CLI_NAME) -Force
    } catch {
        Write-Host-Red "�����ƶ� Lade CLI �ļ�ʧ�ܡ�������Ҫ����ԱȨ�޻�Ŀ¼�����ڡ�"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # �� Lade CLI ���ӵ�ϵͳ PATH �������� (�����δ����)
    # ��ͨ����Ҫ����ԱȨ�޲����޸Ļ�������Ļ���������
    try {
        # [Environment]::GetEnvironmentVariable ��ȡ����������
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        # ��� PATH ���Ƿ��Ѱ�����װ·����
        if (-not ($currentPath -split ';' -contains $LADE_INSTALL_PATH)) {
            Write-Host-Yellow "���ڽ� '$LADE_INSTALL_PATH' ���ӵ�ϵͳ PATH������Ҫ����ԱȨ�ޡ�"
            $newPath = "$currentPath;$LADE_INSTALL_PATH"
            # [Environment]::SetEnvironmentVariable ���û���������
            [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
            Write-Host-Green "Lade CLI ��װ·�������ӵ�ϵͳ PATH����������Ҫ�������� PowerShell �Ự����ʹ����Ч��"
        }
    } catch {
        Write-Host-Yellow "���棺�޷��� Lade CLI ·�����ӵ�ϵͳ PATH �������������ֶ����� '$LADE_INSTALL_PATH' ������ PATH���Ա���κ�λ������ 'lade' ���"
    }

    Write-Host-Green "Lade CLI �ѳɹ����ء���ѹ����װ�� $LADE_INSTALL_PATH"
    Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
    return $true # Lade CLI ��װ�ɹ�
}


# --- ��Ҫִ������ ---

# ��ʾ��ӭҳ��
Display-Welcome

# 2. ȷ�� Lade CLI �Ѱ�װ
# ��� Install-LadeCli ���� false (��װʧ��)�����˳��ű���
if (-not (Install-LadeCli)) {
    Write-Host-Red "����Lade CLI ��װʧ�ܡ��ű����˳���"
    exit 1
}

# --- ���˵� ---
while ($true) { # ����ѭ����ֱ���û�ѡ���˳�
    Write-Host ""
    Write-Host-Cyan "#############################################################"
    Write-Host-Cyan "#          " -NoNewline; Write-Host-Blue "Lade �������˵�" -NoNewline; Write-Host-Cyan "                          #"
    Write-Host-Cyan "#############################################################"
    Write-Host-Green "1. " -NoNewline; Write-Host "���� Ladefree Ӧ��"
    Write-Host-Green "2. " -NoNewline; Write-Host "�鿴���� Lade Ӧ��"
    Write-Host-Green "3. " -NoNewline; Write-Host "ɾ�� Lade Ӧ��"
    Write-Host-Green "4. " -NoNewline; Write-Host "�鿴Ӧ����־"
    Write-Host-Green "5. " -NoNewline; Write-Host "ˢ�� Lade ��¼״̬"
    Write-Host-Red "6. " -NoNewline; Write-Host "�˳�"
    Write-Host-Cyan "-------------------------------------------------------------"
    $CHOICE = Read-Host "��ѡ��һ������ (1-6):"

    switch ($CHOICE) { # �����û�ѡ��ִ����Ӧ����
        "1" { Deploy-App }
        "2" { View-Apps }
        "3" { Delete-App }
        "4" { View-AppLogs }
        "5" { Ensure-LadeLogin }
        "6" { Write-Host-Cyan "�˳��ű����ټ���"; break } # �˳�ѭ��
        default { Write-Host-Red "��Ч��ѡ�������� 1 �� 6 ֮������֡�" }
    }
    Write-Host ""
    Read-Host "�� Enter ������..." | Out-Null # �ȴ��û��� Enter ������
}

Write-Host-Blue "�ű�ִ����ϡ�"
