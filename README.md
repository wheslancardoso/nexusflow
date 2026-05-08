# NexusFlow 🚀

**NexusFlow** (anteriormente ServiceFlow) é uma solução moderna e eficiente para gestão de ordens de serviço e fluxo de trabalho técnico. Desenvolvido em Flutter, o projeto foca em usabilidade, performance e organização para prestadores de serviços.

## ✨ Funcionalidades Principais (Sprint UI - N2)

### 📊 Dashboard Inteligente
- Visualização rápida de KPIs (Total, Em Aberto, Em Execução, Finalizadas).
- Drill-down interativo: clique nos indicadores para ver a lista detalhada de ordens filtradas por status.
- Cálculos automáticos de valores acumulados e contagem de itens.

### 📝 Gestão de Ordens de Serviço
- Cadastro completo com descrição, valor e status semântico.
- Registro visual: suporte a fotos de "Antes" e "Depois" do serviço.
- Assinatura digital integrada para validação do cliente.

### 👥 Gestão de Clientes
- Cadastro de clientes com suporte a CPF/CNPJ.
- Integração fluida com a criação de novas ordens de serviço.

### 🔐 Autenticação e Segurança
- Sistema de login e registro simulado.
- Mixins de validação e feedback visual (Success/Error snacks).

## 🛠️ Arquitetura e Tecnologias

- **Framework:** [Flutter](https://flutter.dev/)
- **Gestão de Estado:** [Provider](https://pub.dev/packages/provider)
- **Injeção de Dependência:** [GetIt](https://pub.dev/packages/get_it)
- **Persistência:** `InMemoryStore` (Primary Source of Truth para a Sprint UI) e `SQLite` para persistência local futura.
- **Design Pattern:** MVVM (Model-View-ViewModel) adaptado.

## 🚀 Como Executar

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/wheslancardoso/nexusflow.git
    ```
2.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```
3.  **Execute o projeto:**
    ```bash
    flutter run
    ```

---
*Desenvolvido por wheslancardoso como parte da avaliação N2.*
