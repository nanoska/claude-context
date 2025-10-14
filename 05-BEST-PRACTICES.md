# 📚 Best Practices - Django, FastAPI, React, PostgreSQL

Este documento consolida mejores prácticas específicas por tecnología.

---

## 🐍 Django Best Practices

### Models

**✅ DO:**
```python
# Use meaningful model names (singular)
class Product(models.Model):
    name = models.CharField(max_length=200, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'products'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['name', 'created_at']),
        ]

    def __str__(self):
        return self.name
```

**❌ DON'T:**
```python
# Avoid generic names, missing indexes
class Item(models.Model):
    n = models.CharField(max_length=200)  # Bad: unclear field name
    # Missing created_at, updated_at
    # Missing indexes
```

### Views & Serializers

**✅ DO: Use ViewSets with proper permissions**
```python
from rest_framework import viewsets, permissions
from rest_framework.decorators import action

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.select_related('category').all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    filterset_fields = ['category', 'price']
    search_fields = ['name', 'description']

    @action(detail=True, methods=['post'])
    def purchase(self, request, pk=None):
        product = self.get_object()
        # Purchase logic
        return Response({'status': 'purchased'})
```

### Migrations

**✅ DO:**
- Always create migrations for model changes
- Name migrations descriptively
- Review migrations before committing

```bash
python manage.py makemigrations --name add_product_stock_field
python manage.py migrate
```

**❌ DON'T:**
- Modify migration files after applying
- Skip migrations
- Edit database directly

### Admin

**✅ DO: Customize admin for better UX**
```python
from django.contrib import admin

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ['name', 'category', 'price', 'stock', 'created_at']
    list_filter = ['category', 'created_at']
    search_fields = ['name', 'description']
    readonly_fields = ['created_at', 'updated_at']
    fieldsets = (
        ('Basic Info', {
            'fields': ('name', 'description', 'category')
        }),
        ('Pricing', {
            'fields': ('price', 'stock')
        }),
    )
```

---

## ⚡ FastAPI Best Practices

### Router Organization

**✅ DO:**
```python
# api/routers/products.py
from fastapi import APIRouter, Depends, HTTPException
from ..models import ProductCreate, ProductResponse
from ..services.products import ProductService

router = APIRouter(prefix="/products", tags=["products"])

@router.get("/", response_model=list[ProductResponse])
async def list_products(
    skip: int = 0,
    limit: int = 10,
    service: ProductService = Depends()
):
    return await service.list_products(skip, limit)

@router.post("/", response_model=ProductResponse, status_code=201)
async def create_product(
    product: ProductCreate,
    service: ProductService = Depends()
):
    return await service.create_product(product)
```

### Pydantic Models

**✅ DO: Use Pydantic for validation**
```python
from pydantic import BaseModel, Field, validator

class ProductCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    price: float = Field(..., gt=0)
    stock: int = Field(..., ge=0)

    @validator('price')
    def price_must_have_two_decimals(cls, v):
        if round(v, 2) != v:
            raise ValueError('Price must have at most 2 decimal places')
        return v
```

### Dependencies

**✅ DO: Use dependency injection**
```python
# api/dependencies.py
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    token = credentials.credentials
    # Verify token
    user = await verify_token(token)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials"
        )
    return user
```

---

## ⚛️ React + TypeScript Best Practices

### Component Structure

**✅ DO: Functional components with TypeScript**
```tsx
interface ProductCardProps {
  product: Product;
  onPurchase: (productId: string) => void;
}

export function ProductCard({ product, onPurchase }: ProductCardProps) {
  const [loading, setLoading] = useState(false);

  const handlePurchase = async () => {
    setLoading(true);
    try {
      await onPurchase(product.id);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="rounded-card shadow-soft p-card">
      <h3 className="text-lg font-semibold">{product.name}</h3>
      <p className="text-gray-600">${product.price}</p>
      <button
        onClick={handlePurchase}
        disabled={loading}
        className="btn-primary"
      >
        {loading ? 'Processing...' : 'Purchase'}
      </button>
    </div>
  );
}
```

### Custom Hooks

**✅ DO: Extract logic to custom hooks**
```tsx
// hooks/useProducts.ts
export function useProducts() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const data = await api.get<Product[]>('/products');
        setProducts(data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);

  return { products, loading, error };
}

// Usage in component
function ProductList() {
  const { products, loading, error } = useProducts();

  if (loading) return <Spinner />;
  if (error) return <Error message={error} />;

  return <div>{products.map(p => <ProductCard key={p.id} product={p} />)}</div>;
}
```

### Type Safety

**✅ DO: Define types centrally**
```typescript
// types/index.ts
export interface Product {
  id: string;
  name: string;
  price: number;
  stock: number;
  createdAt: string;
}

export interface User {
  id: string;
  email: string;
  role: 'admin' | 'user';
}

export type ApiResponse<T> = {
  data: T;
  message: string;
};
```

---

## 🗄️ PostgreSQL Best Practices

### Indexes

**✅ DO: Add indexes for frequently queried fields**
```python
# Django
class Product(models.Model):
    name = models.CharField(max_length=200, db_index=True)
    category = models.ForeignKey('Category', db_index=True)

    class Meta:
        indexes = [
            models.Index(fields=['name', 'category']),
            models.Index(fields=['-created_at']),
        ]
```

### Queries Optimization

**✅ DO: Use select_related and prefetch_related**
```python
# Bad: N+1 queries
products = Product.objects.all()
for product in products:
    print(product.category.name)  # New query each time

# Good: 2 queries total
products = Product.objects.select_related('category').all()
for product in products:
    print(product.category.name)  # No additional query
```

### Transactions

**✅ DO: Use atomic transactions**
```python
from django.db import transaction

@transaction.atomic
def create_order(user, products):
    order = Order.objects.create(user=user)
    for product in products:
        OrderItem.objects.create(order=order, product=product)
        product.stock -= 1
        product.save()
    return order
```

---

## 🔐 Security Best Practices

### Environment Variables

**✅ DO:**
```python
# settings.py
import os
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv('SECRET_KEY')
DEBUG = os.getenv('DEBUG', 'False') == 'True'
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', 'localhost').split(',')
```

**❌ DON'T:**
```python
# Hardcoded secrets
SECRET_KEY = 'django-insecure-hardcoded-key'
DB_PASSWORD = 'mypassword123'
```

### CORS

**✅ DO: Configure CORS properly**
```python
# Django
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "https://myapp.com",
]
CORS_ALLOW_CREDENTIALS = True
```

### SQL Injection Prevention

**✅ DO: Use ORM or parameterized queries**
```python
# Good: Django ORM prevents SQL injection
products = Product.objects.filter(name=user_input)

# Good: Parameterized query
cursor.execute("SELECT * FROM products WHERE name = %s", [user_input])
```

**❌ DON'T:**
```python
# Bad: String concatenation
query = f"SELECT * FROM products WHERE name = '{user_input}'"
cursor.execute(query)  # SQL injection vulnerability
```

---

## 🧪 Testing Best Practices

### Django Tests

**✅ DO:**
```python
from django.test import TestCase
from .models import Product

class ProductModelTest(TestCase):
    def setUp(self):
        self.product = Product.objects.create(
            name="Test Product",
            price=9.99,
            stock=10
        )

    def test_product_creation(self):
        self.assertEqual(self.product.name, "Test Product")
        self.assertEqual(self.product.price, 9.99)

    def test_product_str(self):
        self.assertEqual(str(self.product), "Test Product")
```

### React Tests

**✅ DO:**
```tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { ProductCard } from './ProductCard';

describe('ProductCard', () => {
  const mockProduct = {
    id: '1',
    name: 'Test Product',
    price: 9.99,
  };

  it('renders product name and price', () => {
    render(<ProductCard product={mockProduct} onPurchase={jest.fn()} />);

    expect(screen.getByText('Test Product')).toBeInTheDocument();
    expect(screen.getByText('$9.99')).toBeInTheDocument();
  });

  it('calls onPurchase when button clicked', () => {
    const mockOnPurchase = jest.fn();
    render(<ProductCard product={mockProduct} onPurchase={mockOnPurchase} />);

    fireEvent.click(screen.getByText('Purchase'));

    expect(mockOnPurchase).toHaveBeenCalledWith('1');
  });
});
```

---

## 📦 Dependency Management

### Python (requirements.txt)

**✅ DO: Pin versions**
```txt
Django==5.0.1
djangorestframework==3.14.0
psycopg2-binary==2.9.9
python-dotenv==1.0.0
```

### Node (package.json)

**✅ DO: Use exact versions in production**
```json
{
  "dependencies": {
    "react": "18.2.0",
    "react-dom": "18.2.0"
  },
  "devDependencies": {
    "typescript": "^4.9.5"
  }
}
```

---

## 🚀 Performance

### Django

- Use `select_related()` for ForeignKey
- Use `prefetch_related()` for ManyToMany
- Add database indexes
- Use caching (Redis)

### React

- Use `React.memo()` for expensive components
- Lazy load routes: `React.lazy()`
- Debounce user inputs
- Virtualize long lists

---

**Próximo paso:** Leer `06-AI-AGENT-OPTIMIZATION.md` para optimización de tokens.
