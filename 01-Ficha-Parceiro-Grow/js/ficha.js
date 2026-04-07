// ---- FICHA DO PARCEIRO DETALHADA ----
let currentPartnerId = null;
let agGrids = {};
let vendasChartInstance = null;
let loadedTabs = new Set(); // Controle de abas já carregas para o parceiro atual

// Normalizer
function normalizeSankhyaRows(result) {
    if (!result) return [];
    let rows = [];
    let columns = [];

    if (result.responseBody && result.responseBody.rows) {
        if (result.responseBody.fieldsMetadata) {
            columns = result.responseBody.fieldsMetadata.map(f => f.name);
        }
        let rowsData = result.responseBody.rows;
        if (Array.isArray(rowsData)) {
            rows = rowsData.map(row => {
                let obj = {};
                if (Array.isArray(row)) {
                    row.forEach((val, i) => obj[columns[i] || `col${i}`] = val);
                } else {
                    return row;
                }
                return obj;
            });
        }
    } else if (result._parsed_rows) {
        rows = result._parsed_rows;
    } else if (Array.isArray(result)) {
        rows = result;
    }
    return rows;
}

// Handlers UI
async function openFichaModal(codparc, nomeparc) {
    currentPartnerId = codparc;
    loadedTabs.clear(); // Reseta estado de abas
    
    document.getElementById('modal-partner-name').textContent = nomeparc;
    document.getElementById('modal-partner-cod').textContent = '#' + codparc;
    
    clearFichaUI(); // Limpa dados antigos antes de exibir
    
    document.getElementById('ficha-modal').style.display = 'flex';
    document.body.style.overflow = 'hidden';

    switchTab('tab-geral');
    await loadFichaData(codparc);
}

function clearFichaUI() {
    // 1. Limpa Campos da Aba Geral
    document.getElementById('geral-spc').textContent = 'Carregando...';
    document.getElementById('geral-spc').className = 'spc-status';
    document.getElementById('geral-limites').innerHTML = '<div class="loading-placeholder">...</div>';
    document.getElementById('geral-dados').innerHTML = '<div class="loading-placeholder">...</div>';
    document.getElementById('geral-titulos').innerHTML = '<div class="loading-placeholder">...</div>';

    // 2. Limpa Grids
    Object.keys(agGrids).forEach(gridId => {
        if (agGrids[gridId]) {
            agGrids[gridId].setGridOption('rowData', []);
        }
    });

    // 3. Limpa Gráfico
    if (vendasChartInstance) {
        vendasChartInstance.destroy();
        vendasChartInstance = null;
    }
}

function closeFichaModal() {
    document.getElementById('ficha-modal').style.display = 'none';
    document.body.style.overflow = 'auto';
    currentPartnerId = null;
}

function switchTab(tabId) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));

    const btn = document.querySelector(`button[onclick="switchTab('${tabId}')"]`);
    if (btn) btn.classList.add('active');

    const tab = document.getElementById(tabId);
    if (tab) tab.classList.add('active');

    // Carregamento Lazy
    if (!loadedTabs.has(tabId)) {
        loadTabData(tabId);
    }
}

// CORE FETCH
async function loadFichaData(codparc) {
    const loader = document.getElementById('ficha-loader');
    loader.style.display = 'flex';

    try {
        // Carrega APENAS a aba inicial (Geral) obrigatoriamente
        const resGeral = await executeQuery(Queries.getFichaPrincipal(codparc));
        if (resGeral) {
            renderTabGeral(normalizeSankhyaRows(resGeral));
            loadedTabs.add('tab-geral');
        }
    } catch (e) {
        console.error("Erro no load inicial (Geral)", e);
    } finally {
        loader.style.display = 'none';
    }
}

async function loadTabData(tabId) {
    if (!currentPartnerId || loadedTabs.has(tabId)) return;
    
    const loader = document.getElementById('ficha-loader');
    loader.style.display = 'flex';

    try {
        let result;
        switch(tabId) {
            case 'tab-credito':
                const [resCred, resVinc] = await Promise.all([
                    executeQuery(Queries.getFichaCredito(currentPartnerId)),
                    executeQuery(Queries.getFichaVinculados(currentPartnerId))
                ]);
                renderTabCredito(normalizeSankhyaRows(resCred), normalizeSankhyaRows(resVinc));
                break;
            case 'tab-financeiro':
                result = await executeQuery(Queries.getFichaFinanceiros(currentPartnerId));
                renderTabFinanceiro(normalizeSankhyaRows(result));
                break;
            case 'tab-notas':
                result = await executeQuery(Queries.getFichaNotasProdutos(currentPartnerId));
                renderTabNotas(normalizeSankhyaRows(result));
                break;
            case 'tab-produtos':
                result = await executeQuery(Queries.getFichaProdutos(currentPartnerId));
                renderTabProdutos(normalizeSankhyaRows(result));
                break;
            case 'tab-graficos':
                result = await executeQuery(Queries.getFichaVendasPeriodo(currentPartnerId));
                renderTabGraficos(normalizeSankhyaRows(result));
                break;
        }
        loadedTabs.add(tabId);
    } catch (e) {
        console.error(`Erro ao carregar aba ${tabId}`, e);
    } finally {
        loader.style.display = 'none';
    }
}

// FORMATADORES
const fmtMoney = (val) => formatCurrency(val || 0);

function createAGGrid(containerId, colDefs, rowData) {
    const el = document.getElementById(containerId);
    if (!el) return;
    el.innerHTML = '';

    const gridOptions = {
        columnDefs: colDefs,
        rowData: rowData,
        theme: "ag-theme-quartz-dark", // Usando tema dark pra casar com o fundo
        defaultColDef: {
            sortable: true, filter: true, resizable: true, flex: 1, minWidth: 100
        }
    };

    const grid = agGrid.createGrid(el, gridOptions);
    agGrids[containerId] = grid;
}

function filterGrid(gridId, term) {
    if (agGrids[gridId]) {
        agGrids[gridId].setGridOption('quickFilterText', term);
    }
}

// RENDER TAB GERAL
function renderTabGeral(data) {
    if (!data || data.length === 0) return;
    const row = data[0];

    // SPC
    const spcDiv = document.getElementById('geral-spc');
    spcDiv.textContent = row.SPC || 'Sem Dados';
    spcDiv.className = 'spc-status';
    if (row.COLOR_SPC == 0) spcDiv.classList.add('status-ok');
    else if (row.COLOR_SPC == 1) spcDiv.classList.add('status-danger');
    else spcDiv.classList.add('status-warn');

    // LIMITES
    const limHtml = `
        <div class="info-item"><span class="info-label">Limite Crédito Total</span><span class="info-value">${fmtMoney(row.LIMCRED)}</span></div>
        <div class="info-item"><span class="info-label">Limite Disponível</span><span class="info-value green">${fmtMoney(row.LIMITE_DISP)}</span></div>
        <div class="info-item"><span class="info-label">Crédito UAI / ARTE / FEST</span><span class="info-value">${fmtMoney(row.VLRCRED_UAI)} / ${fmtMoney(row.VLRCRED_ARTE)} / ${fmtMoney(row.VLRCRED_FEST)}</span></div>
        <div class="info-item" style="margin-top:8px; border-top:1px solid rgba(255,255,255,0.1); padding-top:8px;">
            <span class="info-label">Atraso Médio</span><span class="info-value">${row.ATR_MEDIO_DIAS || 0} Dias</span>
        </div>
        <div class="info-item"><span class="info-label">Valor PCLD</span><span class="info-value red">${fmtMoney(row.VLR_PCLD)}</span></div>
    `;
    document.getElementById('geral-limites').innerHTML = limHtml;

    // DADOS COMPLEMENTARES
    const telFmt = formatPhone(row.TELEFONE);
    const celFmt = formatPhone(row.CELULAR);
    const contatosStr = [telFmt, celFmt].filter(Boolean).join(' / ') || '-';

    const dadosHtml = `
        <div class="info-item"><span class="info-label">Cód ERP</span><span class="info-value">${row.CODERP || '-'}</span></div>
        <div class="info-item"><span class="info-label">Documento</span><span class="info-value">${row.CGC_CPF || '-'}</span></div>
        <div class="info-item"><span class="info-label">Contatos</span><span class="info-value">${contatosStr}</span></div>
        <div class="info-item"><span class="info-label">E-mail</span><span class="info-value">${row.EMAIL || '-'}</span></div>
        
        <div class="info-item"><span class="info-label">Endereço</span><span class="info-value">${row.ENDERECO || '-'}</span></div>
        <div class="info-item"><span class="info-label">Cidade / Estado</span><span class="info-value">${row.CIDADE || '-'}</span></div>
        <div class="info-item"><span class="info-label">Dt Cadastro</span><span class="info-value">${formatDateVal(row.DTCAD)}</span></div>
        <div class="info-item"><span class="info-label">Simples Nac.</span><span class="info-value">${row.SIMPLES || '-'}</span></div>
    `;
    document.getElementById('geral-dados').innerHTML = dadosHtml;

    // RESUMO Titulos
    const titHtml = `
        <div class="info-item"><span class="info-label">Qtd. Renegociações</span><span class="info-value">${row.QTD_RENEG || 0}</span></div>
        <div class="info-item"><span class="info-label">Títulos em Aberto</span><span class="info-value green">${fmtMoney(row.TIT_EM_ABERTO)}</span></div>
        <div class="info-item"><span class="info-label">Títulos em Atraso</span><span class="info-value red">${fmtMoney(row.TIT_EM_ATRASO)}</span></div>
        <div class="info-item"><span class="info-label">Último Contato Venda</span><span class="info-value">${formatDateVal(row.ULT_CONTATO)}</span></div>
    `;
    document.getElementById('geral-titulos').innerHTML = titHtml;
}

// Helpers Formats
function formatDateVal(val) {
    if (!val) return '-';
    val = String(val).trim();

    // Identifica o formato cru do banco Oracle via Sankhya: "DDMMYYYY HH:MM:SS" ou "DDMMYYYY"
    if (/^\d{8}/.test(val)) {
        const dd = val.substring(0, 2);
        const mm = val.substring(2, 4);
        const yyyy = val.substring(4, 8);
        return `${dd}/${mm}/${yyyy}`;
    }

    const d = new Date(val);
    if (!isNaN(d)) return d.toLocaleDateString('pt-BR');

    return val;
}

function formatPhone(val) {
    if (!val || val === '—' || val === '-') return '';
    let digits = String(val).replace(/\D/g, '');
    if (digits.length === 11) {
        return `(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}`;
    } else if (digits.length === 10) {
        return `(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}`;
    }
    return String(val).trim();
}

function renderTabCredito(credData, vincData) {
    const credCols = [
        { field: "EMPRESA", headerName: "Empresa" },
        { field: "DTNEG", headerName: "Data Neg", valueFormatter: p => formatDateVal(p.value) },
        { field: "VLRLIQUIDO", headerName: "Valor Líquido", valueFormatter: p => fmtMoney(p.value) }
    ];
    createAGGrid('grid-credito', credCols, credData);

    const vincCols = [
        { field: "CODCTT", headerName: "Cód" },
        { field: "NOMEPARC", headerName: "Nome" },
        { field: "CGCCPF", headerName: "Documento", valueFormatter: p => formatCpfCnpj(p.value) },
        { field: "SIMPLES_GROW", headerName: "Simples Grow" },
        { field: "SIMPLES_ARTE", headerName: "Simples Arte" }
    ];
    createAGGrid('grid-vinculados', vincCols, vincData);
}

function renderTabFinanceiro(data) {
    const cols = [
        { field: "EMPRESA", headerName: "Empresa" },
        { field: "NUMNOTA", headerName: "Num. Nota" },
        { field: "DTNEG", headerName: "Emissão", valueFormatter: p => formatDateVal(p.value) },
        { field: "DTVENC", headerName: "Vencimento", valueFormatter: p => formatDateVal(p.value) },
        { field: "VLRDESDOB", headerName: "Valor R$", valueFormatter: p => fmtMoney(p.value) },
        { field: "VENCIDO", headerName: "Status", cellRenderer: p => p.value == 1 ? '<span class="badge" style="background:var(--accent-red-soft);color:var(--accent-red)">Atrasado</span>' : '<span class="badge" style="background:var(--accent-green-soft);color:var(--accent-green)">A Vencer</span>' }
    ];
    createAGGrid('grid-financeiro', cols, data);
}

function renderTabNotas(data) {
    const cols = [
        { field: "EMPRESA", headerName: "Empresa" },
        { field: "NUNOTA", headerName: "Nº Unico" },
        { field: "NUMNOTA", headerName: "Nota" },
        { field: "DTNEG", headerName: "Data", valueFormatter: p => formatDateVal(p.value) },
        { field: "VENDEDOR", headerName: "Vendedor" },
        { field: "PRODUTO", headerName: "Produto" },
        { field: "QTDNEG", headerName: "Qtd" },
        { field: "VLRLIQ", headerName: "Vlr Líquido", valueFormatter: p => fmtMoney(p.value) }
    ];
    createAGGrid('grid-notas', cols, data);
}

function renderTabProdutos(data) {
    const cols = [
        { field: "DESCRPROD", headerName: "Produto" },
        { field: "QTDNEG", headerName: "Quantidade Contratada" },
        { field: "VLRUNIT", headerName: "Vlr. Unit. Médio", valueFormatter: p => fmtMoney(p.value) }
    ];
    createAGGrid('grid-produtos', cols, data);
}

function renderTabGraficos(data) {
    const ctx = document.getElementById('vendasChart');
    if (!ctx) return;

    if (vendasChartInstance) {
        vendasChartInstance.destroy();
    }

    // Sort chronological: oldest to newest
    const sortedData = [...data].reverse();
    const labels = sortedData.map(r => r.ANO_MES);
    const values = sortedData.map(r => parseFloat(r.VLRFATUR) || 0);

    vendasChartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Faturamento Bruto (R$)',
                data: values,
                backgroundColor: 'rgba(16, 185, 129, 0.6)',
                borderColor: 'rgba(16, 185, 129, 1)',
                borderWidth: 1,
                borderRadius: 4
            }]
        },
        plugins: [{
            id: 'valueLabels',
            afterDatasetsDraw(chart) {
                const { ctx } = chart;
                chart.data.datasets.forEach((dataset, i) => {
                    const meta = chart.getDatasetMeta(i);
                    meta.data.forEach((bar, index) => {
                        const val = dataset.data[index];
                        if (val > 0) {
                            ctx.save();
                            ctx.fillStyle = '#f1f5f9';
                            ctx.font = 'bold 12px sans-serif';
                            ctx.textAlign = 'center';
                            ctx.textBaseline = 'bottom';
                            ctx.fillText(fmtMoney(val), bar.x, bar.y - 5);
                            ctx.restore();
                        }
                    });
                });
            }
        }],
        options: {
            layout: {
                padding: { top: 30 }
            },
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { labels: { color: '#f1f5f9' } }
            },
            scales: {
                y: {
                    ticks: { color: '#94a3b8' },
                    grid: { color: 'rgba(255,255,255,0.05)' }
                },
                x: {
                    ticks: { color: '#94a3b8' },
                    grid: { color: 'rgba(255,255,255,0.05)' }
                }
            }
        }
    });
}
