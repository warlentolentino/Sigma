/**
 * ============================================
 *  GROW - Painel Ficha Parceiro
 *  Lógica principal: Login, Consultas, UI
 * ============================================
 */

// ---- Estado da aplicação ----
const App = {
    isLoggedIn: false,
    sessionCookie: null,
    isLoading: false
};

// ---- Utilitários ----
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

function getBaseUrl() {
    if (typeof CONFIG === 'undefined') {
        showToast('error', 'Arquivo config.js não encontrado. Veja config.example.js para instruções.');
        throw new Error('CONFIG não definido');
    }
    return CONFIG.BASE_URL;
}

// ---- Toast Notifications ----
function showToast(type, message, duration = 5000) {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const icons = {
        success: '✅',
        error: '❌',
        warning: '⚠️'
    };

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `
        <span class="toast-icon">${icons[type] || 'ℹ️'}</span>
        <span>${message}</span>
        <button class="toast-close" onclick="this.parentElement.remove()">✕</button>
    `;
    container.appendChild(toast);

    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateX(40px)';
        toast.style.transition = 'all 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, duration);
}

// ---- Status de Conexão ----
function updateConnectionStatus(online) {
    const badge = document.getElementById('status-badge');
    const dot = document.getElementById('status-dot');
    const text = document.getElementById('status-text');
    const btnLogin = document.getElementById('btn-login');
    const btnLogout = document.getElementById('btn-logout');

    if (online) {
        badge.className = 'status-badge online';
        text.textContent = 'Conectado';
        btnLogin.style.display = 'none';
        btnLogout.style.display = 'inline-flex';
    } else {
        badge.className = 'status-badge offline';
        text.textContent = 'Desconectado';
        btnLogin.style.display = 'inline-flex';
        btnLogout.style.display = 'none';
    }
}

// ---- LOGIN ----
async function doLogin() {
    if (typeof CONFIG === 'undefined') {
        showToast('error', 'Arquivo config.js não encontrado!');
        return false;
    }

    const btnLogin = document.getElementById('btn-login');
    btnLogin.disabled = true;
    btnLogin.innerHTML = '<span class="spinner"></span> Conectando...';

    const xmlBody = `<serviceRequest serviceName="MobileLoginSP.login">
<requestBody>
<NOMUSU>${CONFIG.NOMUSU}</NOMUSU>
<INTERNO>${CONFIG.INTERNO}</INTERNO>
</requestBody>
</serviceRequest>`;

    try {
        const response = await fetch(
            `/api/?serviceName=MobileLoginSP.login`,
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'text/xml;charset=ISO-8859-1'
                },
                body: xmlBody,
                credentials: 'include'
            }
        );

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const arrayBuffer = await response.arrayBuffer();
        const decoder = new TextDecoder('iso-8859-1');
        const responseText = decoder.decode(arrayBuffer);

        // Verifica se o login foi bem sucedido
        if (responseText.includes('statusMessage') && responseText.includes('erro')) {
            const errorMatch = responseText.match(/statusMessage="([^"]+)"/);
            throw new Error(errorMatch ? errorMatch[1] : 'Erro no login');
        }

        App.isLoggedIn = true;
        updateConnectionStatus(true);
        enableSearch(true);
        return true;

    } catch (error) {
        console.error('Erro no login:', error);
        showToast('error', `Falha no login: ${error.message}`);
        App.isLoggedIn = false;
        updateConnectionStatus(false);
        return false;

    } finally {
        btnLogin.disabled = false;
        btnLogin.innerHTML = '🔌 Conectar';
    }
}

// ---- LOGOUT ----
async function doLogout() {
    try {
        await fetch(
            `/api/?serviceName=MobileLoginSP.logout`,
            {
                method: 'POST',
                credentials: 'include'
            }
        );
    } catch (e) {
        console.warn('Erro no logout:', e);
    }

    App.isLoggedIn = false;
    updateConnectionStatus(false);
    enableSearch(false);
    clearResults();
    showToast('warning', 'Sessão encerrada.');
}

// ---- CONSULTA DBEXPLORER ----
async function executeQuery(sql) {
    if (!App.isLoggedIn) {
        showToast('warning', 'Faça login antes de consultar.');
        return null;
    }

    const payload = {
        serviceName: "DbExplorerSP.executeQuery",
        requestBody: {
            sql: sql
        }
    };

    try {
        const response = await fetch(
            `/api/?serviceName=DbExplorerSP.executeQuery`,
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload),
                credentials: 'include'
            }
        );

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const arrayBuffer = await response.arrayBuffer();
        const decoder = new TextDecoder('iso-8859-1');
        const responseText = decoder.decode(arrayBuffer);
        console.log('Resposta bruta do Sankhya:', responseText);

        // Tenta parsear como JSON primeiro
        try {
            const jsonData = JSON.parse(responseText);
            return jsonData;
        } catch (e) {
            // Se não é JSON, parseia como XML
        }

        // Parseia XML
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(responseText, 'text/xml');

        // Verifica erro no XML
        const parseError = xmlDoc.querySelector('parsererror');
        if (parseError) {
            throw new Error('Erro ao parsear resposta XML do Sankhya');
        }

        // Verifica se houve erro no serviço
        const serviceResponse = xmlDoc.querySelector('serviceResponse');
        if (serviceResponse) {
            const status = serviceResponse.getAttribute('status');
            const statusMessage = serviceResponse.getAttribute('statusMessage');
            if (status === '0' || (statusMessage && statusMessage.toLowerCase().includes('erro'))) {
                throw new Error(statusMessage || 'Erro retornado pelo Sankhya');
            }
        }

        // Extrai campos (metadata) e linhas do resultado
        const result = parseXmlDbExplorer(xmlDoc);
        return result;

    } catch (error) {
        console.error('Erro na consulta:', error);
        showToast('error', `Erro na consulta: ${error.message}`);
        return null;
    }
}

// ---- Parseia resposta XML do DbExplorer ----
function parseXmlDbExplorer(xmlDoc) {
    const columns = [];
    const rows = [];

    // Tenta extrair colunas dos fieldsMetadata
    const fieldsMetadata = xmlDoc.querySelectorAll('fieldsMetadata field');
    if (fieldsMetadata.length > 0) {
        fieldsMetadata.forEach(field => {
            columns.push(field.getAttribute('name') || field.textContent);
        });
    }

    // Tenta extrair linhas
    const rowElements = xmlDoc.querySelectorAll('rows row');
    if (rowElements.length > 0) {
        rowElements.forEach(rowEl => {
            const obj = {};
            const values = rowEl.querySelectorAll('column');
            if (values.length > 0) {
                values.forEach((col, idx) => {
                    const key = columns[idx] || `col${idx}`;
                    obj[key] = col.textContent || null;
                });
            } else {
                // Tenta por atributos ou elementos filhos diretos
                if (columns.length > 0) {
                    const children = rowEl.children;
                    for (let i = 0; i < children.length; i++) {
                        const key = columns[i] || children[i].tagName || `col${i}`;
                        obj[key] = children[i].textContent || null;
                    }
                } else {
                    // Usa tag names como keys
                    const children = rowEl.children;
                    for (let i = 0; i < children.length; i++) {
                        obj[children[i].tagName] = children[i].textContent || null;
                    }
                }
            }
            rows.push(obj);
        });
    }

    // Se não encontrou structured data, tenta formato alternativo
    if (rows.length === 0) {
        // Procura qualquer elemento com dados tabulares
        const allElements = xmlDoc.querySelectorAll('responseBody *');
        console.log('Elementos no responseBody:', allElements.length);

        // Log para debug
        const responseBody = xmlDoc.querySelector('responseBody');
        if (responseBody) {
            console.log('responseBody XML:', responseBody.innerHTML || responseBody.outerHTML);
        }
    }

    return {
        responseBody: {
            fieldsMetadata: columns.map(name => ({ name })),
            rows: rows
        },
        _raw_columns: columns,
        _parsed_rows: rows
    };
}

// ---- BUSCA DE PARCEIRO ----
async function searchPartner() {
    const searchValue = document.getElementById('search-value').value.trim();

    if (!searchValue) {
        clearResults();
        return;
    }

    if (!App.isLoggedIn) {
        showToast('warning', 'Conecte-se antes de pesquisar.');
        return;
    }

    // Busca Inteligente: Identifica se é número, nome ou documento
    let whereClause = '';

    if (searchValue.startsWith('#')) {
        // Busca explícita por código do parceiro (ex: #6715)
        const code = parseInt(searchValue.substring(1));
        if (!isNaN(code)) {
            whereClause = `PAR.CODPARC = ${code}`;
        } else {
            clearResults();
            return;
        }
    } else {
        const isOnlyNumbers = /^\d+$/.test(searchValue);

        if (isOnlyNumbers && searchValue.length <= 6) {
            // Provável código
            whereClause = `(PAR.CODPARC = ${parseInt(searchValue)} OR PAR.CGCCPF LIKE '${searchValue}%')`;
        } else {
            // Provável Nome ou CPF/CNPJ
            const cleanDoc = searchValue.replace(/\D/g, '');
            if (cleanDoc.length >= 11) {
                whereClause = `PAR.CGCCPF LIKE '${cleanDoc}%'`;
            } else {
                whereClause = `(PAR.NOMEPARC LIKE '%${searchValue.toUpperCase()}%' OR CAST(PAR.CODPARC AS VARCHAR2(20)) LIKE '%${searchValue}%')`;
            }
        }
    }

    const sql = `
        SELECT 
            PAR.CODPARC,
            PAR.NOMEPARC,
            PAR.CGCCPF,
            PAR.TELEFONE,
            PAR.CELULAR,
            PAR.EMAIL,
            CID.NOMECID,
            CID.UF,
            PAR.LIMCREDITO
        FROM GROWPRD.TGFPAR PAR
        LEFT JOIN GROWPRD.TSICID CID ON PAR.CODCID = CID.CODCID
        WHERE ${whereClause}
        ORDER BY PAR.NOMEPARC

    `.trim();

    // Mostra loading
    showLoading(true);

    const data = await executeQuery(sql);

    showLoading(false);

    if (data) {
        renderResults(data);
    }
}

// ---- RENDERIZAÇÃO ----
function renderResults(data) {
    const container = document.getElementById('results-container');
    const countEl = document.getElementById('results-count');

    // Tenta extrair registros do response do Sankhya
    let rows = [];
    let columns = [];

    try {
        // Estrutura típica do DbExplorer response
        if (data.responseBody && data.responseBody.rows) {
            const rowsData = data.responseBody.rows;

            // Pega os nomes das colunas do metadata
            if (data.responseBody.fieldsMetadata) {
                columns = data.responseBody.fieldsMetadata.map(f => f.name);
            }

            // Converte rows em objetos
            if (Array.isArray(rowsData)) {
                rows = rowsData.map(row => {
                    const obj = {};
                    if (Array.isArray(row)) {
                        row.forEach((val, idx) => {
                            obj[columns[idx] || `col${idx}`] = val;
                        });
                    } else {
                        return row;
                    }
                    return obj;
                });
            }
        }
    } catch (e) {
        console.warn('Erro ao parsear resposta:', e, data);
        // Tenta mostrar dados brutos
        rows = Array.isArray(data) ? data : [data];
    }

    // Atualiza contador
    countEl.innerHTML = `<span>${rows.length}</span> registro(s) encontrado(s)`;

    if (rows.length === 0) {
        container.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">📭</div>
                <h3 class="empty-state-title">Nenhum registro encontrado</h3>
                <p class="empty-state-description">Tente pesquisar com outro termo ou verifique se os dados estão corretos.</p>
            </div>
        `;
        return;
    }

    // Renderiza como cards
    const cardsHtml = rows.map((row, index) => {
        const nome = row.NOMEPARC || '—';
        const codparc = row.CODPARC || '—';
        const cgc = formatCpfCnpj(row.CGCCPF) || '—';
        
        const telFmt = formatPhone(row.TELEFONE);
        const celFmt = formatPhone(row.CELULAR);
        const contatosStr = [telFmt, celFmt].filter(Boolean).join(' / ') || '—';

        const email = row.EMAIL || '—';
        const cidade = row.NOMECID || '—';
        const uf = row.UF || '—';
        const limCred = row.LIMCREDITO ? formatCurrency(row.LIMCREDITO) : '—';

        const safeNome = nome.replace(/'/g, "\\'").replace(/"/g, "&quot;");
        return `
            <div class="data-card" style="animation-delay: ${index * 0.08}s; cursor: pointer;" onclick="openFichaModal('${codparc}', '${safeNome}')" title="Clique para abrir a Ficha Completa">
                <div class="data-card-header">
                    <div>
                        <div class="data-card-title">${escapeHtml(nome)}</div>
                    </div>
                    <span class="data-card-id">#${codparc}</span>
                </div>
                <div class="data-card-body">
                    <div class="data-row">
                        <span class="data-label">CPF/CNPJ</span>
                        <span class="data-value">${cgc}</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label">Contatos</span>
                        <span class="data-value">${contatosStr}</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label">E-mail</span>
                        <span class="data-value">${escapeHtml(email)}</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label">Cidade</span>
                        <span class="data-value">${escapeHtml(cidade)} / ${escapeHtml(uf)}</span>
                    </div>
                    <div class="data-row">
                        <span class="data-label">Lim. Crédito</span>
                        <span class="data-value">${limCred}</span>
                    </div>
                </div>
            </div>
        `;
    }).join('');

    container.innerHTML = `<div class="card-grid">${cardsHtml}</div>`;
}

// ---- Helpers de UI ----
function enableSearch(enabled) {
    const searchValue = document.getElementById('search-value');
    const btnSearch = document.getElementById('btn-search');

    searchValue.disabled = !enabled;
    btnSearch.disabled = !enabled;

    if (enabled) {
        searchValue.focus();
    }
}

function showLoading(show) {
    const container = document.getElementById('results-container');
    if (show) {
        container.innerHTML = `
            <div class="loading-overlay">
                <span class="spinner"></span>
                Consultando dados...
            </div>
        `;
    }
}

function clearResults() {
    const container = document.getElementById('results-container');
    const countEl = document.getElementById('results-count');
    container.innerHTML = `
        <div class="empty-state">
            <div class="empty-state-icon">🔍</div>
            <h3 class="empty-state-title">Pesquise um parceiro</h3>
            <p class="empty-state-description">Conecte-se ao Grow e utilize a barra de pesquisa para buscar dados de parceiros.</p>
        </div>
    `;
    countEl.innerHTML = '';
}

// ---- Formatadores ----
function formatCpfCnpj(value) {
    if (!value) return null;
    const digits = String(value).replace(/\D/g, '');
    if (digits.length === 11) {
        return digits.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
    } else if (digits.length === 14) {
        return digits.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
    }
    return value;
}

function formatPhone(val) {
    if (!val || val === '—' || val === '-') return '';
    let digits = String(val).replace(/\D/g, '');
    if (digits.length === 11) {
        return `(${digits.substring(0,2)}) ${digits.substring(2,7)}-${digits.substring(7)}`;
    } else if (digits.length === 10) {
        return `(${digits.substring(0,2)}) ${digits.substring(2,6)}-${digits.substring(6)}`;
    }
    return String(val).trim();
}

function formatCurrency(value) {
    const num = parseFloat(value);
    if (isNaN(num)) return value;
    return num.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
}

function escapeHtml(text) {
    if (typeof text !== 'string') return text;
    const map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
    return text.replace(/[&<>"']/g, m => map[m]);
}

// ---- Event Listeners ----
document.addEventListener('DOMContentLoaded', () => {
    updateConnectionStatus(false);
    enableSearch(false);
    clearResults();

    // Iniciar sessão Sankhya logo no load
    doLogin().then(() => {
        const urlParams = new URLSearchParams(window.location.search);
        const urlCodParc = urlParams.get('codparc');
        if (urlCodParc) {
            const valEl = document.getElementById('search-value');
            if (valEl) {
                valEl.value = urlCodParc;
                // Dispara a pesquisa e já abre o card após renderizar
                searchPartner().then(() => {
                    // Timeout pequeno para garantir a injeção no DOM do card HTML
                    setTimeout(() => {
                        const firstCard = document.querySelector('.data-card');
                        if (firstCard) firstCard.click();
                    }, 200);
                });
            }
        }
    });

    // Busca dinâmica com debounce (500ms)
    const searchInput = document.getElementById('search-value');
    if (searchInput) {
        const dynamicSearch = debounce(() => {
            searchPartner();
        }, 500);

        searchInput.addEventListener('input', dynamicSearch);

        searchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                searchPartner(); // Busca imediata no Enter
            }
        });
    }
});
