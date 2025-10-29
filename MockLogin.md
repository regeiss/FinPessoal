# Mock de Autenticação - FinPessoal

## Visão Geral

O sistema de mock de autenticação permite desenvolver e testar o app sem precisar de login real, Firebase ou conexão com internet. É especialmente útil durante o desenvolvimento e testes.

## Configuração Rápida

### 1. Ativar Mock de Autenticação

No arquivo `FinPessoalApp+Mock.swift`, configure:

```swift
struct AppConfiguration {
  static let useMockAuth = true      // ✅ Ativa o mock
  static let autoLogin = true        // ✅ Login automático
  static let skipOnboarding = true   // ✅ Pula onboarding
}
```

### 2. Tipos de Usuário Disponíveis

- **Regular**: Usuário padrão com configurações básicas
- **Premium**: Usuário com recursos avançados habilitados  
- **New User**: Usuário recém-cadastrado

### 3. Cenários de Teste

```swift
enum MockScenario {
  case loggedIn     // Usuário já logado
  case loggedOut    // Usuário deslogado
  case premiumUser  // Usuário premium
  case newUser      // Usuário novo
}
```

## Como Usar

### Login Automático (Recomendado para Desenvolvimento)

```swift
// No AppConfiguration
static let useMockAuth = true
static let autoLogin = true
```

O app iniciará automaticamente com um usuário logado.

### Login Manual com Mock

```swift
// No AppConfiguration  
static let useMockAuth = true
static let autoLogin = false
```

Isso mostrará a tela de login, mas com funcionalidade mock.

### Botões de Desenvolvimento

Quando `useMockAuth = true`, o app mostra:

1. **Botão flutuante laranja** (canto inferior direito):
   - Quick Login - Regular
   - Quick Login - Premium  
   - Quick Login - New User
   - Force Logout
   - Simulate Errors
   - Debug Info

2. **Botões na tela de login** (se `autoLogin = false`):
   - Login Rápido
   - Usuário Premium

## Funcionalidades do Mock

### ✅ Implementado

- ✅ Login com email/senha
- ✅ Cadastro de usuário
- ✅ Login com Google (simulado)
- ✅ Login com Apple (simulado)
- ✅ Logout
- ✅ Verificação de estado de autenticação
- ✅ Simulação de erros de rede
- ✅ Diferentes tipos de usuário
- ✅ Delay de rede simulado
- ✅ Validações básicas

### 🚀 Casos de Uso

#### Desenvolvimento Normal
```swift
// Configuração mais simples
static let useMockAuth = true
static let autoLogin = true
static let skipOnboarding = true
```

#### Teste de Fluxo de Login
```swift
static let useMockAuth = true
static let autoLogin = false
static let skipOnboarding = false
```

#### Teste de Diferentes Usuários
```swift
// Use os botões de desenvolvimento ou
static let mockScenario: MockScenario = .premiumUser
```

## Emails de Teste Especiais

O mock reconhece alguns emails especiais:

- `error@test.com` → Simula erro de credenciais
- `existing@test.com` → Simula email já cadastrado (no signup)
- Qualquer outro email → Login/cadastro bem-sucedido

## Debugging

### Ver informações do usuário atual
```swift
print(authViewModel.debugInfo)
```

### Forçar logout
```swift
authViewModel.forceLogout()
```

### Simular erros
```swift
authViewModel.simulateAuthError(.networkError)
```

## Mudança para Produção

⚠️ **IMPORTANTE**: Antes de fazer build de produção:

```swift
struct AppConfiguration {
  static let useMockAuth = false  // 🔴 DESATIVAR em produção
  static let autoLogin = false
  static let skipOnboarding = false
}
```

## Estrutura de Arquivos

```
FinPessoal/
├── Code/Features/Authentication/
│   ├── Repository/
│   │   ├── AuthRepository.swift
│   │   └── MockAuthRepository.swift          // ✅ Mock principal
│   ├── ViewModel/
│   │   ├── AuthViewModel.swift
│   │   └── AuthViewModel+Mock.swift          // ✅ Extensões mock
│   └── Screen/
│       └── LoginScreen.swift
├── FinPessoalApp.swift
└── FinPessoalApp+Mock.swift                  // ✅ Configuração mock
```

## Benefícios

✅ **Desenvolvimento mais rápido** - Sem necessidade de login real  
✅ **Testes independentes** - Funciona offline  
✅ **Múltiplos cenários** - Teste diferentes tipos de usuário  
✅ **Simulação realista** - Inclui delays e erros  
✅ **Fácil configuração** - Uma flag para ativar/desativar  
✅ **Debug facilitado** - Informações detalhadas disponíveis  

## Troubleshooting

### App não entra automaticamente
- Verifique se `useMockAuth = true`
- Verifique se `autoLogin = true`
- Confira se o `AuthViewModel` está usando o mock

### Botões de desenvolvimento não aparecem
- Confirme `useMockAuth = true`
- Verifique se está em build Debug

### Erros de compilação
- Certifique-se de que todos os arquivos mock foram adicionados ao projeto
- Verifique imports necessários

## Próximos Passos

Para usar o mock:

1. Substitua o conteúdo de `MockAuthRepository.swift` pelo código fornecido
2. Adicione o arquivo `AuthViewModel+Mock.swift` ao projeto
3. Substitua o conteúdo de `FinPessoalApp.swift` pelo código com configurações mock
4. Configure `useMockAuth = true` no `AppConfiguration`
5. Execute o app - deve entrar automaticamente sem login!
