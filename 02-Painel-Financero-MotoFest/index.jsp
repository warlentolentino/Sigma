<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
  <!DOCTYPE html>
  <%@ page import="java.util.*" %>
    <%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
      <%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
        <html>

        <head>
          <snk:load />
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          <title>Painel Financeiro - MotoFest</title>

          <style>
            /* =========================
   VARIÃVEIS DE TEMA
========================= */

            :root {
              --bi-primary: #143F73;
              --bi-secondary: #1F4F8C;

              --bi-bg: #F4F6F8;
              --bi-card: #FFFFFF;

              --bi-border: #E6EAF0;

              --bi-text: #0D1B2A;
              --bi-sub: #4B5B6B;

              --bi-success: #2E7D32;
              --bi-warning: #F9A825;
              --bi-danger: #C62828;

              --bi-radius: 12px;

              --bi-shadow:
                0 4px 14px rgba(13, 27, 42, .06);
            }

            /* =========================
   BASE
========================= */

            body {
              margin: 0;
              font-family:
                system-ui,
                -apple-system,
                Segoe UI,
                Roboto,
                Arial,
                sans-serif;

              background: var(--bi-bg);
              color: var(--bi-text);
            }

            * {
              box-sizing: border-box;
            }

            /* =========================
   CONTAINER PRINCIPAL
========================= */

            .app {
              width: 100%;
              min-height: 100vh;
            }

            /* =========================
   HEADER DO DASHBOARD
========================= */

            .topbar {

              display: flex;

              justify-content: space-between;

              align-items: flex-start;

              gap: 14px;

              padding: 16px;
            }

            .title {
              display: flex;
              flex-direction: row;
              align-items: center;
              gap: 12px;
            }

            .title h1 {

              margin: 0;

              font-size: 26px;

              font-weight: 800;

              color: var(--bi-primary);
            }

            .title .sub {

              font-size: 12px;

              color: var(--bi-sub);
            }

            /* =========================
   FILTROS
========================= */

            .filters {

              display: flex;

              align-items: center;

              gap: 10px;

              flex: 1;
            }

            /* =========================
   CAMPO DE BUSCA
========================= */

            .input {
              display: flex;
              align-items: center;
              gap: 8px;
              background: #fff;
              border: 1px solid var(--bi-border);
              border-radius: var(--bi-radius);
              padding: 8px 12px;
              flex: 0 1 250px;
              min-width: 200px;
              box-shadow: var(--bi-shadow);
            }

            .input input {

              border: 0;

              outline: none;

              width: 100%;

              background: transparent;

              font-size: 13px;

              color: var(--bi-text);
            }

            /* =========================
   BOTÃ•ES
========================= */

            .btn {

              display: inline-flex;

              align-items: center;

              gap: 6px;

              padding: 8px 14px;

              border-radius: var(--bi-radius);

              font-size: 13px;

              font-weight: 700;

              cursor: pointer;

              border: 1px solid transparent;
            }

            .btn-primary {

              background: var(--bi-secondary);

              color: #fff;

              border-color: var(--bi-secondary);
            }

            .btn-primary:hover {

              filter: brightness(.95);
            }

            /* =========================
   ÃREA DE CONTEÃšDO
========================= */

            .content {

              padding: 14px;

              display: grid;

              grid-template-rows: auto 1fr;

              gap: 12px;

              height: calc(100vh - 90px);
            }

            /* =========================
   KPIs
========================= */

            .kpis {

              display: grid;

              grid-template-columns: repeat(4, 1fr);

              gap: 12px;
            }

            .card {

              background: var(--bi-card);

              border: 1px solid var(--bi-border);

              border-radius: var(--bi-radius);

              padding: 12px;

              box-shadow: var(--bi-shadow);
            }

            .label {

              font-size: 12px;

              color: var(--bi-sub);

              font-weight: 600;
            }

            .value {

              font-size: 24px;

              font-weight: 900;

              margin-top: 4px;

              color: var(--bi-primary);
            }

            .hint {

              font-size: 11px;

              color: var(--bi-sub);
            }

            /* =========================
   GRID CONTAINER
========================= */

            .gridWrap {

              background: #fff;

              border: 1px solid var(--bi-border);

              border-radius: var(--bi-radius);

              padding: 10px;

              box-shadow: var(--bi-shadow);

              display: flex;

              flex-direction: column;

              min-height: 0;
            }

            /* =========================
   BADGES
========================= */

            .badge {

              padding: 2px 8px;

              border-radius: 20px;

              font-size: 11px;

              font-weight: 700;

              background: #EEF3F8;

              color: #2F4F6F;
            }

            /* =========================
   FAROL
========================= */

            .dot {

              width: 12px;

              height: 12px;

              border-radius: 50%;
            }

            .dot.ok {
              background: var(--bi-success);
            }

            .dot.warn {
              background: var(--bi-warning);
            }

            .dot.bad {
              background: var(--bi-danger);
            }

            /* =========================
   RESPONSIVO
========================= */

            @media(max-width:1200px) {

              .kpis {
                grid-template-columns: repeat(2, 1fr);
              }

            }

            @media(max-width:700px) {

              .kpis {
                grid-template-columns: 1fr;
              }

            }

            .gridWrap {
              background: #fff;
              border: 1px solid var(--bi-border);
              border-radius: var(--bi-radius);
              box-shadow: var(--bi-shadow);
              padding: 10px;
              min-height: 0;
              display: flex;
              flex-direction: column;
            }

            .grid-toolbar {
              margin-bottom: 8px;
              display: flex;
              gap: 8px;
              align-items: center;
              flex-wrap: wrap;
            }

            #myGrid,
            .bi-grid {
              width: 100%;
              flex: 1 1 auto;
              min-height: 420px;
            }

            .ag-theme-alpine,
            .ag-theme-alpine-dark {
              --ag-font-size: 13px;
              --ag-font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
              --ag-border-color: var(--bi-border);
              --ag-header-background-color: #F8FAFC;
              --ag-odd-row-background-color: #FCFDFE;
              --ag-row-hover-color: #F4F8FC;
              --ag-selected-row-background-color: rgba(31, 79, 140, .10);
              --ag-range-selection-border-color: rgba(31, 79, 140, .25);
              --ag-borders: solid 1px;
              --ag-border-radius: 10px;
            }

            .ag-theme-alpine .ag-root-wrapper {
              border-radius: 10px;
              border-color: var(--bi-border);
            }

            .ag-theme-alpine .ag-header {
              background: #F8FAFC;
            }

            .ag-theme-alpine .ag-header-cell {
              border-right: 1px solid #EEF2F6;
            }

            .ag-theme-alpine .ag-header-cell-label {
              font-weight: 800;
              color: #203040;
            }

            .ag-theme-alpine .ag-row {
              font-size: 13px;
            }

            .ag-theme-alpine .ag-cell {
              display: flex;
              align-items: center;
              border-right: 1px solid #F3F6F9;
            }

            .ag-theme-alpine .ag-cell-wrap-text {
              line-height: 1.2;
            }

            .ag-theme-alpine .ag-paging-panel {
              border-top: 1px solid #EEF2F6;
              color: var(--bi-sub);
            }

            .ag-right-cell {
              justify-content: flex-end;
            }

            .ag-center-cell {
              justify-content: center;
            }

            .ag-left-cell {
              justify-content: flex-start;
            }

            .ag-right-header .ag-header-cell-label {
              justify-content: flex-end;
            }

            .ag-center-header .ag-header-cell-label {
              justify-content: center;
            }

            .grid-missing {
              display: none;
              margin-top: 8px;
              font-size: 12px;
              color: #7A8794;
            }

            .fallbackWrap {
              display: none;
              overflow: auto;
              border: 1px solid var(--bi-border);
              border-radius: 10px;
              background: #fff;
            }

            .fallbackTable {
              width: 100%;
              border-collapse: collapse;
              font-size: 13px;
            }

            .fallbackTable th,
            .fallbackTable td {
              border-bottom: 1px solid #EEF2F6;
              padding: 8px 10px;
              vertical-align: middle;
            }

            .fallbackTable thead th {
              position: sticky;
              top: 0;
              z-index: 1;
              background: #F8FAFC;
              color: #203040;
              font-weight: 800;
              text-align: left;
            }

            .fallbackTable tbody tr:hover {
              background: #FAFCFE;
            }

            .fallbackTable .right {
              text-align: right;
            }

            .fallbackTable .center {
              text-align: center;
            }

            .fallbackTable .wrap {
              white-space: normal;
            }

            .grid-empty {
              padding: 18px;
              text-align: center;
              color: #7A8794;
            }

            @media (max-width:780px) {

              #myGrid,
              .bi-grid {
                min-height: 340px;
              }

              .grid-toolbar {
                align-items: stretch;
              }
            }

            .kpis {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
              gap: 8px;
            }

            .kpi-card {
              background: var(--bi-card);
              border: 2px solid transparent;
              border-radius: 8px;
              box-shadow: var(--bi-shadow);
              padding: 8px 10px;
              min-height: 60px;
              position: relative;
              overflow: hidden;
              cursor: pointer;
              transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
            }

            .kpi-card:hover {
              transform: translateY(-2px);
              box-shadow: 0 8px 16px rgba(13, 27, 42, .08);
            }

            .kpi-card.active {
              border-color: var(--bi-secondary);
              background-color: #FAFCFF;
            }

            .kpi-card::before {
              content: "";
              position: absolute;
              left: 0;
              top: 0;
              width: 4px;
              height: 100%;
              background: #DCE6F2;
            }

            .kpi-card.primary::before {
              background: var(--bi-primary);
            }

            .kpi-card.success::before {
              background: var(--bi-success);
            }

            .kpi-card.warning::before {
              background: var(--bi-warning);
            }

            .kpi-card.danger::before {
              background: var(--bi-danger);
            }

            .kpi-label {
              font-size: 10px;
              color: var(--bi-sub);
              font-weight: 700;
              line-height: 1.1;
              white-space: nowrap;
              overflow: hidden;
              text-overflow: ellipsis;
            }

            .kpi-value {
              margin-top: 4px;
              font-size: 16px;
              font-weight: 900;
              color: var(--bi-primary);
              line-height: 1.1;
            }

            .kpi-sub {
              margin-top: 2px;
              font-size: 10px;
              color: var(--bi-sub);
              line-height: 1.2;
            }

            .kpi-value.mono {
              font-variant-numeric: tabular-nums;
            }

            .kpi-row {
              display: flex;
              align-items: center;
              justify-content: space-between;
              gap: 10px;
            }

            .kpi-icon {
              width: 36px;
              height: 36px;
              border-radius: 10px;
              display: inline-flex;
              align-items: center;
              justify-content: center;
              font-weight: 900;
              background: #EEF3F8;
              color: var(--bi-primary);
              flex: 0 0 auto;
            }

            .kpi-card.success .kpi-icon {
              background: rgba(46, 125, 50, .12);
              color: var(--bi-success);
            }

            .kpi-card.warning .kpi-icon {
              background: rgba(249, 168, 37, .15);
              color: #9A6700;
            }

            .kpi-card.danger .kpi-icon {
              background: rgba(198, 40, 40, .12);
              color: var(--bi-danger);
            }

            .kpi-trend {
              display: inline-flex;
              align-items: center;
              gap: 4px;
              margin-top: 6px;
              font-size: 11px;
              font-weight: 800;
            }

            .kpi-trend.up {
              color: var(--bi-success);
            }

            .kpi-trend.down {
              color: var(--bi-danger);
            }

            .kpi-trend.flat {
              color: var(--bi-sub);
            }

            .kpi-compact {
              min-height: 68px;
              padding: 10px 12px;
            }

            .kpi-compact .kpi-value {
              font-size: 20px;
            }

            .kpi-muted .kpi-value {
              color: var(--bi-text);
            }

            .kpi-hidden {
              display: none !important;
            }

            @media (max-width:1400px) {
              .kpis {
                grid-template-columns: repeat(3, minmax(0, 1fr));
              }
            }

            @media (max-width:780px) {
              .kpis {
                grid-template-columns: repeat(2, minmax(0, 1fr));
              }
            }

            .date-filter {
              display: flex;
              align-items: center;
              gap: 8px;
              background: #fff;
              border: 1px solid var(--bi-border);
              border-radius: var(--bi-radius);
              padding: 0 12px;
              height: 40px;
              white-space: nowrap;
            }

            .date-filter .lbl {
              font-size: 11px;
              color: var(--bi-sub);
              font-weight: 600;
              text-transform: uppercase;
              letter-spacing: 0.5px;
            }

            .date-filter input {
              border: none;
              outline: none;
              color: var(--bi-text);
              background: transparent;
              font-size: 13px;
              font-family: inherit;
              font-weight: 500;
              width: 110px;
            }
          </style>
          <!-- AG Grid -->
          <link rel="stylesheet" href="https://unpkg.com/ag-grid-community@25.0.0/dist/styles/ag-grid.css" />
          <link rel="stylesheet" href="https://unpkg.com/ag-grid-community@25.0.0/dist/styles/ag-theme-alpine.css" />
          <script src="https://unpkg.com/ag-grid-enterprise@25.0.0/dist/ag-grid-enterprise.min.js"></script>

          <script>


            window.BIUtils = (function () {
              'use strict';

              function qsa(sel, root) {
                return Array.prototype.slice.call((root || document).querySelectorAll(sel));
              }

              function qs(sel, root) {
                return (root || document).querySelector(sel);
              }

              function esc(s) {
                return String(s || '').replace(/[&<>"']/g, function (c) {
                  return {
                    '&': '&amp;',
                    '<': '&lt;',
                    '>': '&gt;',
                    '"': '&quot;',
                    "'": '&#39;'
                  }[c];
                });
              }

              function isNil(v) {
                return v === null || v === undefined;
              }

              function toStr(v, def) {
                if (isNil(v)) return def || '';
                return String(v);
              }

              function parseNum(v) {
                if (isNil(v)) return 0;

                if (typeof v === 'number') {
                  return isNaN(v) ? 0 : v;
                }

                var s = String(v).trim();
                if (!s) return 0;

                s = s.replace(/[^\d,\.\-]/g, '');

                if (s.indexOf(',') >= 0) {
                  s = s.replace(/\./g, '').replace(',', '.');
                }

                var n = Number(s);
                return isNaN(n) ? 0 : n;
              }

              function fmtNum(n, frac) {
                var f = (frac === undefined ? 0 : frac);
                try {
                  return Number(n || 0).toLocaleString('pt-BR', {
                    minimumFractionDigits: f,
                    maximumFractionDigits: f
                  });
                } catch (e) {
                  return String(n || 0);
                }
              }

              function fmtBRL(n) {
                try {
                  return Number(n || 0).toLocaleString('pt-BR', {
                    style: 'currency',
                    currency: 'BRL'
                  });
                } catch (e) {
                  return 'R$ ' + fmtNum(n || 0, 2);
                }
              }

              function fmtPct(n, frac) {
                var f = (frac === undefined ? 2 : frac);
                return fmtNum(n || 0, f) + '%';
              }

              function sum(arr, field) {
                return (arr || []).reduce(function (acc, item) {
                  return acc + parseNum(item[field]);
                }, 0);
              }

              function countBy(arr, field, value) {
                return (arr || []).filter(function (item) {
                  return String(item[field] || '').toUpperCase() === String(value || '').toUpperCase();
                }).length;
              }

              function groupBy(arr, field) {
                return (arr || []).reduce(function (acc, item) {
                  var key = item[field];
                  if (!acc[key]) acc[key] = [];
                  acc[key].push(item);
                  return acc;
                }, {});
              }

              function textContains(row, fields, q) {
                if (!q) return true;
                q = String(q).toLowerCase();

                var hay = (fields || []).map(function (f) {
                  return String(row[f] || '');
                }).join(' ').toLowerCase();

                return hay.indexOf(q) >= 0;
              }

              function sortRows(arr, sortKey, sortDir) {
                var mult = sortDir === 'asc' ? 1 : -1;

                return (arr || []).slice().sort(function (a, b) {
                  var va = a[sortKey];
                  var vb = b[sortKey];

                  var na = typeof va === 'number';
                  var nb = typeof vb === 'number';

                  if (na || nb) {
                    va = Number(va || 0);
                    vb = Number(vb || 0);
                    return (va - vb) * mult;
                  }

                  return String(va || '').localeCompare(String(vb || ''), 'pt-BR') * mult;
                });
              }

              function setText(id, value) {
                var el = document.getElementById(id);
                if (el) el.textContent = value;
              }

              function setHtml(id, value) {
                var el = document.getElementById(id);
                if (el) el.innerHTML = value;
              }

              function resolveEl(elOrSelector) {
                if (!elOrSelector) return null;
                if (typeof elOrSelector !== 'string') return elOrSelector;

                return document.getElementById(elOrSelector) || document.querySelector(elOrSelector);
              }

              function show(elOrSelector) {
                var el = resolveEl(elOrSelector);
                if (el) el.style.display = '';
              }

              function hide(elOrSelector) {
                var el = resolveEl(elOrSelector);
                if (el) el.style.display = 'none';
              }

              function hideBySelector(sel) {
                qsa(sel).forEach(function (el) {
                  el.style.display = 'none';
                });
              }

              function showBySelector(sel) {
                qsa(sel).forEach(function (el) {
                  el.style.display = '';
                });
              }

              function statusBadge(v) {
                var s = String(v || '').toUpperCase();

                if (s === 'OK' || s === 'VERDE') {
                  return '<span class="badge badge-success">' + esc(v) + '</span>';
                }

                if (s === 'ALERTA' || s === 'AMARELO') {
                  return '<span class="badge badge-warning">' + esc(v) + '</span>';
                }

                if (s === 'CRITICO' || s === 'CRÃTICO' || s === 'VERMELHO') {
                  return '<span class="badge badge-danger">' + esc(v) + '</span>';
                }

                return '<span class="badge">' + esc(v || '-') + '</span>';
              }

              function farolDot(v) {
                var s = String(v || '').toUpperCase();

                if (s === 'VERDE' || s === 'OK') {
                  return '<span class="dot ok" title="' + esc(s) + '"></span>';
                }

                if (s === 'AMARELO' || s === 'ALERTA') {
                  return '<span class="dot warn" title="' + esc(s) + '"></span>';
                }

                if (s === 'VERMELHO' || s === 'CRITICO' || s === 'CRÃTICO') {
                  return '<span class="dot bad" title="' + esc(s) + '"></span>';
                }

                return '';
              }

              function getVisibleGridRows(gridApi) {
                if (!gridApi) return null;

                var out = [];
                try {
                  gridApi.forEachNodeAfterFilterAndSort(function (node) {
                    if (node && node.data) out.push(node.data);
                  });
                } catch (e) {
                  return null;
                }

                return out;
              }

              function applyQuickFilter(inputId, state, refreshFn) {
                var el = document.getElementById(inputId);
                if (!el) return;

                el.addEventListener('input', function () {
                  state.q = (this.value || '').toLowerCase().trim();
                  refreshFn();
                });
              }

              function hideKpisForNonGestor(selector) {
                if (window.USUARIO_LOGADO && window.USUARIO_LOGADO.ad_gestor === 'S') return;
                hideBySelector(selector || '.kpis .kpi-card, .kpis .card');
              }

              function setAgGridLicense() {
                try {
                  var AG = window.agGrid;
                  if (
                    AG &&
                    AG.LicenseManager &&
                    AG.LicenseManager.setLicenseKey
                  ) {
                    AG.LicenseManager.setLicenseKey(
                      'Sankhya_Gestao_de_Negocios_Sankhya-W_2Devs6_November_2020__MTYwNDYyMDgwMDAwMA==1f914bb75813904547879033c6de21d2'
                    );
                  }
                } catch (e) { }
              }

              function cleanSankhyaUI() {
                try {
                  [window.parent, window.parent && window.parent.parent]
                    .filter(Boolean)
                    .forEach(function (frame) {
                      var doc = frame.document;
                      if (!doc) return;

                      [
                        'button.chartConfigButton',
                        '.VCompactBar',
                        '.VCompactBar-opened',
                        '.VCompactBar-closed'
                      ].forEach(function (sel) {
                        doc.querySelectorAll(sel).forEach(function (el) {
                          el.remove();
                        });
                      });
                    });
                } catch (e) { }
              }

              function bootCleanSankhyaUI() {
                [0, 400, 1200, 3000].forEach(function (t) {
                  setTimeout(cleanSankhyaUI, t);
                });
              }

              return {
                qsa: qsa,
                qs: qs,
                esc: esc,
                isNil: isNil,
                toStr: toStr,
                parseNum: parseNum,
                fmtNum: fmtNum,
                fmtBRL: fmtBRL,
                fmtPct: fmtPct,
                sum: sum,
                countBy: countBy,
                groupBy: groupBy,
                textContains: textContains,
                sortRows: sortRows,
                setText: setText,
                setHtml: setHtml,
                show: show,
                hide: hide,
                hideBySelector: hideBySelector,
                showBySelector: showBySelector,
                statusBadge: statusBadge,
                farolDot: farolDot,
                getVisibleGridRows: getVisibleGridRows,
                applyQuickFilter: applyQuickFilter,
                hideKpisForNonGestor: hideKpisForNonGestor,
                setAgGridLicense: setAgGridLicense,
                cleanSankhyaUI: cleanSankhyaUI,
                bootCleanSankhyaUI: bootCleanSankhyaUI
              };
            })();

          </script>
          <!-- CONSULTA DE DADOS -->
          <snk:query var="dados">
            SELECT *
            FROM AD_VGFFIN_FEST
            ORDER BY 5 ASC
          </snk:query>
        </head>

        <body>
          <!-- RESERVATÓRIO DE DADOS -->
          <div id="dataRows" style="display:none;">
            <c:forEach items="${dados.rows}" var="r">
              <span class="r" data-empresa="${r.EMPRESA}" data-codcloud="${r.CODCLOUD}" data-pessoa="${r.PESSOA}"
                data-documento="${r.DOCUMENTO}" data-dtneg="${r.DTNEG}" data-dtvenc="${r.DTVENC}"
                data-portador="${r.PORTADOR}" data-valor="${r.VALOR}" data-observacao="${r.OBSERVACAO}"
                data-modalidade="${r.MODALIDADE}" data-spc="${r.SPC}" data-pcld="${r.PCLD}"
                data-restricao="${r.RESTRICAO}" data-cnpjparc="${r.CNPJPARC}"></span>
            </c:forEach>
          </div>

          <div class="app">
            <div class="topbar">
              <div class="title" style="display: flex; align-items: center; gap: 12px;">
                <img
                  src="data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAUAAAABCCAIAAACpTZhCAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyhpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMTQ1IDc5LjE2MzQ5OSwgMjAxOC8wOC8xMy0xNjo0MDoyMiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTkgKE1hY2ludG9zaCkiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MDQ5NjBDN0RDQjc3MTFFOTkyMDVFMTNGMURDODdCMjIiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MDQ5NjBDN0VDQjc3MTFFOTkyMDVFMTNGMURDODdCMjIiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDowNDk2MEM3QkNCNzcxMUU5OTIwNUUxM0YxREM4N0IyMiIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDowNDk2MEM3Q0NCNzcxMUU5OTIwNUUxM0YxREM4N0IyMiIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pi+zemoAAHYTSURBVHja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"
                  alt="MotoFest" style="height: 40px; border-radius: 4px;" />
                <h1 id="biTitulo">Painel Financeiro MotoFest</h1>
              </div>

              <div class="filters">
                <div class="date-filter">
                  <span class="lbl">Venc.</span>
                  <input id="fDtIni" type="date" />
                  <span class="lbl">até</span>
                  <input id="fDtFim" type="date" />
                </div>
                <div class="input">
                  <input id="q" type="text" placeholder="Buscar cliente, documento..." />
                </div>
                <button type="button" class="btn btn-primary" onclick="window.location.reload();">
                  Atualizar
                </button>
              </div>
            </div>

            <div class="content">
              <div class="kpis" id="kpiArea">
                <div class="kpi-card primary active" id="cardAberto" onclick="setKpiFilter('todos')">
                  <div class="kpi-label">Total em Aberto (Limpar)</div>
                  <div class="kpi-value mono" id="kpiTotalAberto">R$ 0,00</div>
                  <div class="kpi-sub" id="subTotalAberto">0 títulos</div>
                </div>

                <div class="kpi-card danger" id="cardAtraso" onclick="setKpiFilter('atraso')">
                  <div class="kpi-label">Total em Atraso</div>
                  <div class="kpi-value mono" id="kpiTotalAtraso">R$ 0,00</div>
                  <div class="kpi-sub" id="subTotalAtraso">0 títulos</div>
                </div>

                <div class="kpi-card" style="cursor: default;">
                  <div class="kpi-label">Média por Título</div>
                  <div class="kpi-value mono" id="kpiMedia">R$ 0,00</div>
                  <div class="kpi-sub">Valor médio</div>
                </div>

                <div class="kpi-card warning" id="cardRestricao" onclick="setKpiFilter('restricao')">
                  <div class="kpi-label">Títulos C/ Restrição</div>
                  <div class="kpi-value mono" id="kpiRestricao" style="color: #F9A825;">R$ 0,00</div>
                  <div class="kpi-sub" id="subRestricao">0 títulos</div>
                </div>

                <div class="kpi-card warning" id="cardSpc" onclick="setKpiFilter('spc')">
                  <div class="kpi-label">Títulos no SPC</div>
                  <div class="kpi-value mono" id="kpiSpc" style="color: #F9A825;">R$ 0,00</div>
                  <div class="kpi-sub" id="subSpc">0 títulos</div>
                </div>

                <div class="kpi-card warning" id="cardPcld" onclick="setKpiFilter('pcld')">
                  <div class="kpi-label">Títulos PCLD</div>
                  <div class="kpi-value mono" id="kpiPcld" style="color: #F9A825;">R$ 0,00</div>
                  <div class="kpi-sub" id="subPcld">0 títulos</div>
                </div>

                <div class="kpi-card" style="cursor: default;">
                  <div class="kpi-label">% Em Dia</div>
                  <div class="kpi-value mono" id="kpiPctEmDia" style="color: #2E7D32;">0,0%</div>
                  <div class="kpi-sub" id="subPctEmDia">0 títulos</div>
                </div>

                <div class="kpi-card" style="cursor: default;">
                  <div class="kpi-label">% Em Atraso</div>
                  <div class="kpi-value mono" id="kpiPctEmAtraso" style="color: #C62828;">0,0%</div>
                  <div class="kpi-sub" id="subPctEmAtraso">0 títulos</div>
                </div>

                <div class="kpi-card" style="cursor: default;">
                  <div class="kpi-label">Atraso Médio</div>
                  <div class="kpi-value mono" id="kpiMediaAtraso" style="color: #C62828;">0 dias</div>
                  <div class="kpi-sub">Faturas vencidas</div>
                </div>
              </div>

              <div class="gridWrap">
                <div id="myGrid" class="ag-theme-alpine" style="height: 100%; width: 100%;"></div>
                <div class="foot" id="foot">—</div>
              </div>
            </div>
          </div>

          <script>
            const U = BIUtils;
            U.bootCleanSankhyaUI();
            U.setAgGridLicense();

            // Carregar dados do reservatório (inicial)
            var rows = U.qsa('#dataRows .r').map(function (el) {
              const dtvencStr = el.getAttribute('data-dtvenc');

              let vencDateObj = null;
              if (dtvencStr) {
                const parts = dtvencStr.split(' ')[0].split('-');
                if (parts.length === 3) {
                  vencDateObj = new Date(parts[0], parts[1] - 1, parts[2]);
                }
              }

              return {
                empresa: el.getAttribute('data-empresa') || '',
                codcloud: el.getAttribute('data-codcloud') || '',
                pessoa: el.getAttribute('data-pessoa') || '',
                documento: el.getAttribute('data-documento') || '',
                dtneg: el.getAttribute('data-dtneg') || '',
                dtvenc: dtvencStr,
                vencDate: vencDateObj,
                portador: el.getAttribute('data-portador') || '',
                valor: U.parseNum(el.getAttribute('data-valor')),
                observacao: el.getAttribute('data-observacao') || '',
                modalidade: el.getAttribute('data-modalidade') || '',
                spc: el.getAttribute('data-spc') || '',
                pcld: el.getAttribute('data-pcld') || '',
                restricao: el.getAttribute('data-restricao') || '',
                cnpjparc: el.getAttribute('data-cnpjparc') || ''
              };
            });

            var state = { q: '', dtIni: '', dtFim: '', kpiFilter: 'todos' };
            var gridApi = null;

            function setKpiFilter(filterType) {
              state.kpiFilter = filterType;

              // Remover active de todos
              U.qsa('.kpi-card').forEach(c => c.classList.remove('active'));

              // Adicionar active no clicado
              if (filterType === 'todos') document.getElementById('cardAberto').classList.add('active');
              if (filterType === 'atraso') document.getElementById('cardAtraso').classList.add('active');
              if (filterType === 'restricao') document.getElementById('cardRestricao').classList.add('active');
              if (filterType === 'spc') document.getElementById('cardSpc').classList.add('active');
              if (filterType === 'pcld') document.getElementById('cardPcld').classList.add('active');

              if (gridApi) gridApi.onFilterChanged();
            }

            function isAtrasadoDateObj(venc) {
              if (!venc) return false;
              const hoje = new Date();
              hoje.setHours(0, 0, 0, 0);
              return venc < hoje;
            }

            function isAtrasado(dtStr) {
              if (!dtStr) return false;
              try {
                const parts = dtStr.split(' ')[0].split('-');
                if (parts.length === 3) {
                  const venc = new Date(parts[0], parts[1] - 1, parts[2]);
                  return isAtrasadoDateObj(venc);
                }
              } catch (e) { }
              return false;
            }

            function updateKpis(arr) {
              const total = U.sum(arr, 'valor');

              const hoje = new Date();
              hoje.setHours(0, 0, 0, 0);

              const atrasados = arr.filter(r => r.vencDate && r.vencDate < hoje);
              const totalAtraso = U.sum(atrasados, 'valor');
              const media = arr.length > 0 ? total / arr.length : 0;

              const emDia = arr.filter(r => r.vencDate && r.vencDate >= hoje);
              const pctEmDia = arr.length > 0 ? (emDia.length / arr.length) * 100 : 0;
              const pctEmAtraso = arr.length > 0 ? (atrasados.length / arr.length) * 100 : 0;

              let somaDiasAtraso = 0;
              atrasados.forEach(r => {
                somaDiasAtraso += Math.floor((hoje - r.vencDate) / 86400000);
              });
              const mediaDiasAtraso = atrasados.length > 0 ? Math.round(somaDiasAtraso / atrasados.length) : 0;

              const restricoes = arr.filter(r => r.restricao === 'Sim');
              const totalRestricoes = U.sum(restricoes, 'valor');

              const arrSpc = arr.filter(r => r.spc === 'Sim');
              const totalSpc = U.sum(arrSpc, 'valor');

              const arrPcld = arr.filter(r => r.pcld === 'Sim');
              const totalPcld = U.sum(arrPcld, 'valor');

              U.setText('kpiTotalAberto', U.fmtBRL(total));
              U.setText('subTotalAberto', arr.length + ' títulos');
              U.setText('kpiTotalAtraso', U.fmtBRL(totalAtraso));
              U.setText('subTotalAtraso', atrasados.length + ' títulos em atraso');
              U.setText('kpiMedia', U.fmtBRL(media));

              U.setText('kpiRestricao', U.fmtBRL(totalRestricoes));
              U.setText('subRestricao', restricoes.length + ' títulos');

              U.setText('kpiSpc', U.fmtBRL(totalSpc));
              U.setText('subSpc', arrSpc.length + ' títulos');

              U.setText('kpiPcld', U.fmtBRL(totalPcld));
              U.setText('subPcld', arrPcld.length + ' títulos');

              U.setText('kpiPctEmDia', U.fmtNum(pctEmDia, 1) + '%');
              U.setText('subPctEmDia', emDia.length + ' em dia');

              U.setText('kpiPctEmAtraso', U.fmtNum(pctEmAtraso, 1) + '%');
              U.setText('subPctEmAtraso', atrasados.length + ' atrasados');

              U.setText('kpiMediaAtraso', mediaDiasAtraso + ' dias');

              U.setText('foot', 'Registros: ' + arr.length + ' - Atualizado: ' + new Date().toLocaleString());
            }

            function setupGrid() {
              const columnDefs = [
                { headerName: 'Empresa', field: 'empresa', width: 130 },
                { headerName: 'Cód. Cloud', field: 'codcloud', width: 130 },
                { headerName: 'Parceiro/Pessoa', field: 'pessoa', flex: 1, minWidth: 200 },
                {
                  headerName: 'CNPJ',
                  field: 'cnpjparc',
                  width: 160,
                  getQuickFilterText: p => p.value ? p.value + ' ' + p.value.replace(/\D/g, '') : ''
                },
                {
                  headerName: 'Documento',
                  field: 'documento',
                  width: 150,
                  getQuickFilterText: p => p.value ? p.value + ' ' + p.value.replace(/\D/g, '') : ''
                },
                {
                  headerName: 'Dt. Neg.',
                  field: 'dtneg',
                  width: 130,
                  cellClass: 'ag-center-cell',
                  valueFormatter: p => p.value ? p.value.split(' ')[0].split('-').reverse().join('/') : ''
                },
                {
                  headerName: 'Vencimento',
                  field: 'dtvenc',
                  width: 130,
                  cellClass: 'ag-center-cell',
                  valueFormatter: p => p.value ? p.value.split(' ')[0].split('-').reverse().join('/') : ''
                },
                {
                  headerName: 'Valor',
                  field: 'valor',
                  width: 120,
                  valueFormatter: p => U.fmtBRL(p.value),
                  cellClass: 'ag-right-cell mono'
                },
                { headerName: 'Modalidade', field: 'modalidade', width: 140 },
                { headerName: 'Portador', field: 'portador', width: 180 },
                {
                  headerName: 'Restrição',
                  field: 'restricao',
                  width: 130,
                  cellRenderer: p => p.value === 'Sim' ? `<span class="badge" style="background:#C62828;color:#fff;">Sim</span>` : `Não`,
                  cellClass: 'ag-center-cell'
                },
                { headerName: 'SPC', field: 'spc', width: 80, cellClass: 'ag-center-cell' },
                { headerName: 'PCLD', field: 'pcld', width: 120, cellClass: 'ag-center-cell' },
                { headerName: 'Observação', field: 'observacao', width: 220 }
              ];

              const gridOptions = {
                columnDefs: columnDefs,
                rowData: rows,
                pagination: true,
                paginationPageSize: 50,
                defaultColDef: { sortable: true, filter: true, resizable: true },
                rowClassRules: {
                  'row-overdue-red': params => params.data.vencDate && isAtrasadoDateObj(params.data.vencDate)
                },
                isExternalFilterPresent: function () {
                  return state.dtIni !== '' || state.dtFim !== '' || state.kpiFilter !== 'todos';
                },
                doesExternalFilterPass: function (node) {
                  const d = node.data;

                  if (state.kpiFilter !== 'todos') {
                    if (state.kpiFilter === 'atraso' && !(d.vencDate && isAtrasadoDateObj(d.vencDate))) return false;
                    if (state.kpiFilter === 'restricao' && d.restricao !== 'Sim') return false;
                    if (state.kpiFilter === 'spc' && d.spc !== 'Sim') return false;
                    if (state.kpiFilter === 'pcld' && d.pcld !== 'Sim') return false;
                  }

                  if (state.dtIni || state.dtFim) {
                    if (!d.vencDate) return false;

                    if (state.dtIni) {
                      const iniParts = state.dtIni.split('-');
                      const dtI = new Date(iniParts[0], iniParts[1] - 1, iniParts[2]);
                      if (d.vencDate < dtI) return false;
                    }
                    if (state.dtFim) {
                      const fimParts = state.dtFim.split('-');
                      const dtF = new Date(fimParts[0], fimParts[1] - 1, fimParts[2]);
                      if (d.vencDate > dtF) return false;
                    }
                  }

                  return true;
                },
                onGridReady: params => {
                  gridApi = params.api;
                  updateKpis(rows);
                },
                onFilterChanged: () => {
                  const filtered = [];
                  gridApi.forEachNodeAfterFilter(node => filtered.push(node.data));
                  updateKpis(filtered);
                }
              };

              const eGridDiv = document.querySelector('#myGrid');
              if (eGridDiv) {
                new agGrid.Grid(eGridDiv, gridOptions);
              }
            }

            // Mudar CSS para injetar o row-overdue-red dinâmico
            var extStyle = document.createElement('style');
            extStyle.innerHTML = `.row-overdue-red { color: #C62828 !important; font-weight: 600; } .row-overdue-red .ag-cell { color: #C62828 !important; }`;
            document.head.appendChild(extStyle);

            // Filtro rápido texto
            const filterInput = document.getElementById('q');
            if (filterInput) {
              filterInput.addEventListener('input', function () {
                if (gridApi) gridApi.setQuickFilter(this.value);
              });
            }

            // Filtros Data
            const filterIni = document.getElementById('fDtIni');
            const filterFim = document.getElementById('fDtFim');

            function onDateChanged() {
              state.dtIni = filterIni ? filterIni.value : '';
              state.dtFim = filterFim ? filterFim.value : '';
              if (gridApi) gridApi.onFilterChanged();
            }

            if (filterIni) filterIni.addEventListener('change', onDateChanged);
            if (filterFim) filterFim.addEventListener('change', onDateChanged);

            setupGrid();
          </script>
        </body>

        </html>