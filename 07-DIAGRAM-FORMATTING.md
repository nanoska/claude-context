# 📊 Diagram Formatting Rules for Project Documentation

Este archivo define los **estándares de visualización** para documentación técnica en todos los proyectos.

## 🎯 Objetivo

Todos los diagramas deben generarse en **formatos basados en texto** que puedan renderizarse en markdown, git, o entornos VSCode (GitHub, Obsidian, Cursor, Vercel Docs).

---

## 🧠 General Guidelines

- Siempre usar **formatos basados en texto** (Mermaid, PlantUML, Graphviz DOT, o extensiones de Markdown) — no imágenes a menos que se solicite explícitamente.
- Los diagramas deben ser **copy-paste runnable**, permitiendo renderizado o edición instantánea.
- Usar **nombres de nodos consistentes** con etiquetas claras (evitar oraciones largas).
- Cuando sea posible, **agrupar secciones por etapa**: Frontend / Backend / Infra / Data.

---

## 🧭 Format Rules by Diagram Type

### 1️⃣ **Process or Flow Documentation**

Usar **Mermaid flowcharts**:

```markdown
```mermaid
flowchart TD
    A[User Request] --> B[API Gateway]
    B --> C[Django Backend]
    C --> D[(PostgreSQL)]
    D --> E[Response to User]
```
```

**Directivas disponibles:**
- `TD` → top to bottom
- `LR` → left to right
- `RL` → right to left
- `BT` → bottom to top

**Formas de nodos:**
- `[]` → proceso rectangular
- `[()]` → base de datos / storage
- `{}` → decisión / condicional
- `(())` → círculo / evento
- `[[ ]]` → subroutine / módulo

---

### 2️⃣ **API or System Interactions**

Usar **sequence diagrams** para mostrar flujo de mensajes entre componentes:

```markdown
```mermaid
sequenceDiagram
    participant U as User
    participant F as Frontend (React)
    participant B as Backend (FastAPI)
    participant DB as Database

    U->>F: Sends request
    F->>B: Calls endpoint /api/data
    B->>DB: Query
    DB-->>B: Data
    B-->>F: JSON response
    F-->>U: Rendered view
```
```

**Tipos de flechas:**
- `->>` → mensaje síncrono
- `-->>` → respuesta / mensaje asíncrono
- `-x` → mensaje que falla
- `-->` → mensaje dotted

---

### 3️⃣ **Database Models / ORM**

Usar **Mermaid ER diagrams** para relaciones entre entidades:

```markdown
```mermaid
erDiagram
    USER ||--o{ ENROLLMENT : enrolls
    TEACHER ||--o{ WORKSHOP : teaches
    WORKSHOP ||--o{ ENROLLMENT : contains
    ENROLLMENT {
        int id
        date created_at
        float amount_paid
    }
    USER {
        int id
        string email
        string name
    }
```
```

**Cardinalidades:**
- `||--||` → one to one
- `||--o{` → one to many
- `}o--o{` → many to many
- `||--o|` → one to zero or one

---

### 4️⃣ **Software Architecture / Components**

Usar **PlantUML component diagrams** cuando la arquitectura involucra múltiples servicios o containers:

```plantuml
@startuml
component "Frontend (React)" as FE
component "Backend (Django)" as BE
database "PostgreSQL" as DB
cloud "AWS S3" as S3

FE --> BE
BE --> DB
BE --> S3
@enduml
```

**Cuándo usar PlantUML vs Mermaid:**
- ✅ PlantUML: Arquitecturas complejas, múltiples capas, deployment diagrams
- ✅ Mermaid: Casos más simples, mejor soporte en GitHub/VSCode

---

### 5️⃣ **Infrastructure (AWS / Docker / Cloud)**

Usar **Graphviz DOT** notation para infraestructura:

```dot
digraph G {
  rankdir=LR;
  Frontend -> Backend -> Database;
  Backend -> S3;
  Backend -> "n8n Workflow";
}
```

**Alternativa: Python Diagrams** (cuando se necesita código ejecutable):

```python
from diagrams import Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS

with Diagram("AWS Architecture"):
    EC2("Web Server") >> RDS("Database")
```

---

### 6️⃣ **Project Timelines or Phases**

Usar **Mermaid Gantt** para sprints o milestones:

```markdown
```mermaid
gantt
    title EMPIV Project Timeline
    dateFormat  YYYY-MM-DD
    section Phase 1 - Integration
    Backend & DB Setup        :done,    p1, 2025-01-01,2025-01-31
    section Phase 2 - ML MVP
    Model Training            :active,  p2, 2025-02-01,2025-02-28
    section Phase 3 - Frontend
    UI Components             :         p3, 2025-03-01,2025-03-31
```
```

**Estados disponibles:**
- `done` → tarea completada
- `active` → tarea en progreso
- `crit` → tarea crítica
- `milestone` → hito importante

---

### 7️⃣ **State Machines / Workflows**

Usar **Mermaid state diagrams** para estados y transiciones:

```markdown
```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> Review: Submit
    Review --> Approved: Accept
    Review --> Draft: Reject
    Approved --> Published: Publish
    Published --> [*]
```
```

---

### 8️⃣ **Class Diagrams / OOP Structure**

Usar **Mermaid class diagrams** para diseño orientado a objetos:

```markdown
```mermaid
classDiagram
    class Product {
        +int id
        +string name
        +float price
        +int stock
        +calculateTotal()
        +updateStock()
    }

    class Order {
        +int id
        +date created_at
        +addProduct()
    }

    Order "1" --> "*" Product: contains
```
```

---

## 🧩 Output Rules for Claude

Cuando documentes o respondas con diagramas:

1. **Detectar** el contexto (flow, arquitectura, modelo de datos, etc.)
2. **Seleccionar** el formato correspondiente de arriba
3. **Envolver** el output entre triple backticks con el tag de lenguaje apropiado
4. Si hay múltiples diagramas, incluir un título corto arriba de cada uno

---

## ✅ Example Combined Output

Al documentar un sistema completo, combinar múltiples tipos de diagramas:

```markdown
### EMPIV System Overview

#### System Flow
```mermaid
flowchart LR
    A[User Login] --> B[Django Auth]
    B --> C[Dashboard View]
    C --> D[(PostgreSQL)]
```

#### Data Model

```mermaid
erDiagram
    TEACHER ||--o{ WORKSHOP : teaches
    WORKSHOP ||--o{ ENROLLMENT : includes
    STUDENT ||--o{ ENROLLMENT : registers
```

#### API Interaction

```mermaid
sequenceDiagram
    participant U as User
    participant F as Frontend
    participant B as Backend
    participant D as Database

    U->>F: Login request
    F->>B: POST /auth/login
    B->>D: Validate credentials
    D-->>B: User data
    B-->>F: JWT token
    F-->>U: Redirect to dashboard
```
```

---

## 📌 Priority Hierarchy

Cuando elijas el formato, usa este orden de prioridad:

**1. Mermaid** (default, mejor soporte)
   - ✅ GitHub native rendering
   - ✅ VSCode plugins
   - ✅ Obsidian support
   - ✅ Fácil de editar

**2. PlantUML** (arquitecturas complejas)
   - ✅ Más opciones de visualización
   - ✅ UML completo
   - ⚠️ Requiere plugin/renderer

**3. Graphviz DOT** (infraestructura)
   - ✅ Grafos complejos
   - ✅ Control fino de layout
   - ⚠️ Requiere Graphviz instalado

**4. Python Diagrams** (infra como código)
   - ✅ Diagramas ejecutables
   - ✅ Iconos de cloud providers
   - ⚠️ Requiere ejecución, no inline

---

## 🎨 Best Practices

### ✅ DO (Hacer)

1. **Nombres descriptivos pero concisos**
   ```mermaid
   flowchart LR
       A[User Authentication] --> B[JWT Generation]
   ```

2. **Agrupar componentes relacionados**
   ```mermaid
   flowchart TD
       subgraph Frontend
           A[React App]
           B[Components]
       end
       subgraph Backend
           C[Django]
           D[FastAPI]
       end
       A --> C
       A --> D
   ```

3. **Incluir leyendas cuando sea necesario**
   ```mermaid
   flowchart TD
       A[Process] -->|success| B[Next Step]
       A -->|failure| C[Error Handler]
   ```

### ❌ DON'T (No hacer)

1. **Evitar oraciones largas en nodos**
   ```mermaid
   flowchart LR
       A[This is a very long description that makes the diagram hard to read]
   ```

2. **No crear diagramas demasiado complejos** (dividir en múltiples)
   - Si un diagrama tiene más de 15-20 nodos, considera dividirlo

3. **No usar imágenes cuando el texto es posible**
   - ❌ ![diagram.png]
   - ✅ ```mermaid ... ```

---

## 📚 Quick Reference

| Necesitas mostrar... | Usar... | Formato |
|----------------------|---------|---------|
| Flujo de proceso | Mermaid Flowchart | `flowchart TD/LR` |
| Comunicación API | Mermaid Sequence | `sequenceDiagram` |
| Modelo de datos | Mermaid ER | `erDiagram` |
| Arquitectura de sistema | PlantUML Component | `@startuml` |
| Infraestructura cloud | Graphviz DOT | `digraph G` |
| Timeline / Sprint | Mermaid Gantt | `gantt` |
| Estados / Workflow | Mermaid State | `stateDiagram-v2` |
| Clases OOP | Mermaid Class | `classDiagram` |

---

## 🔗 Referencias

- [Mermaid Documentation](https://mermaid.js.org/)
- [PlantUML Documentation](https://plantuml.com/)
- [Graphviz Documentation](https://graphviz.org/)
- [Python Diagrams](https://diagrams.mingrammer.com/)

---

**Próximo paso:** Aplicar estos estándares en toda la documentación del proyecto para mejorar comprensión y comunicación.
