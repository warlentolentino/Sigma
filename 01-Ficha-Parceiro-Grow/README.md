# 01-Ficha-Parceiro-Grow

**Grow** — Painel de consulta de ficha de parceiros integrado ao Sankhya ERP via API DbExplorer.

## 🚀 Setup

1. Copie o arquivo `config.example.js` para `js/config.js`:
   ```
   copy config.example.js js\config.js
   ```

2. Edite `js/config.js` com suas credenciais reais do Sankhya:
   ```js
   const CONFIG = {
       BASE_URL: "https://sistema.motoarte.com/mge/service.sbr",
       NOMUSU: "SeuUsuario",
       INTERNO: "SuaSenha"
   };
   ```

3. Abra `index.html` no navegador (ou use Live Server no VS Code).

## ⚠️ Segurança

O arquivo `js/config.js` **NÃO é versionado** — ele está no `.gitignore`.  
Nunca commite credenciais no repositório.

## 📁 Estrutura

```
01-Ficha-Parceiro-Grow/
├── index.html            # Página principal
├── css/
│   └── style.css         # Estilos (dark theme)
├── js/
│   ├── app.js            # Lógica da aplicação
│   └── config.js         # 🔒 Credenciais (não versionado)
├── config.example.js     # Template de configuração
├── .gitignore
└── README.md
```

## 🔧 Tecnologias

- HTML5 + CSS3 + JavaScript (vanilla)
- API Sankhya (MobileLoginSP / DbExplorerSP)
- Design: Dark Theme, Glassmorphism, Google Fonts (Inter)
