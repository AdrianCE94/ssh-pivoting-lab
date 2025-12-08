# Contribuir a SSH Pivoting Lab

¡Gracias por tu interés en contribuir! 🎉

## 📋 Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [Cómo Contribuir](#cómo-contribuir)
- [Reporte de Bugs](#reporte-de-bugs)
- [Sugerencias de Features](#sugerencias-de-features)
- [Pull Requests](#pull-requests)
- [Guía de Estilo](#guía-de-estilo)

## 📜 Código de Conducta

Este proyecto sigue un código de conducta. Al participar, se espera que mantengas este código.

### Principios:

- 🤝 Ser respetuoso con otros contribuidores
- 💬 Usar lenguaje inclusivo
- 🎯 Enfocarse en lo mejor para la comunidad
- 📚 Mantener el propósito educativo del proyecto

## 🤝 Cómo Contribuir

### Áreas donde puedes contribuir:

1. **Nuevos Ejercicios**: Añadir ejercicios de pivoting
2. **Documentación**: Mejorar guías existentes
3. **Traducciones**: Traducir a otros idiomas
4. **Herramientas**: Añadir nuevas herramientas a los contenedores
5. **Bugs**: Corregir problemas reportados
6. **Tests**: Añadir scripts de testing

## 🐛 Reporte de Bugs

Si encuentras un bug:

1. Verifica que no esté ya reportado en [Issues](https://github.com/AdrianCE94/ssh-pivoting-lab/issues)
2. Usa la plantilla de Bug Report
3. Incluye:
   - Descripción clara del problema
   - Pasos para reproducir
   - Comportamiento esperado vs actual
   - Tu entorno (OS, Docker version, etc.)
   - Logs relevantes

## 💡 Sugerencias de Features

Para sugerir nuevas características:

1. Abre un Issue usando la plantilla Feature Request
2. Describe claramente:
   - El problema que resuelve
   - Tu solución propuesta
   - Alternativas consideradas
   - Impacto educativo

## 🔀 Pull Requests

### Proceso:

1. **Fork** el repositorio
2. **Clona** tu fork:
   ```bash
   git clone https://github.com/tu-usuario/ssh-pivoting-lab.git
   ```
3. **Crea una rama** para tu feature:
   ```bash
   git checkout -b feature/nombre-descriptivo
   ```
4. **Realiza tus cambios**
5. **Commit** con mensajes claros:
   ```bash
   git commit -m "feat: Añade ejercicio de SSH tunneling avanzado"
   ```
6. **Push** a tu fork:
   ```bash
   git push origin feature/nombre-descriptivo
   ```
7. **Abre un Pull Request** desde GitHub

### Formato de commits:

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` Nueva característica
- `fix:` Corrección de bug
- `docs:` Solo cambios en documentación
- `style:` Formateo, sin cambios de código
- `refactor:` Refactorización de código
- `test:` Añadir tests
- `chore:` Cambios en build, CI, etc.

Ejemplos:
```bash
feat: añade ejercicio de pivoting con Metasploit
fix: corrige problema de conectividad en red interna
docs: actualiza README con nuevos prerrequisitos
```

### Checklist del PR:

- [ ] Los cambios han sido probados localmente
- [ ] La documentación está actualizada
- [ ] Los commits siguen el formato convencional
- [ ] No hay conflictos con main
- [ ] Se añadieron tests si aplica

## 📝 Guía de Estilo

### Código

- **Bash Scripts**: Usar `shellcheck` para validar
- **Docker**: Seguir best practices de Docker
- **Documentación**: Markdown con formato consistente

### Documentación

- Usa encabezados claros
- Incluye ejemplos de código
- Añade emojis para mejor lectura (opcional)
- Mantén líneas de máximo 100 caracteres

### Ejemplos de código

```bash
# ✅ BUENO: Comentarios claros, manejo de errores
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado"
    exit 1
fi

# ❌ MALO: Sin comentarios, sin manejo de errores
docker-compose up -d
```

## 🧪 Testing

Antes de enviar un PR:

```bash
# Limpiar entorno anterior
./scripts/cleanup.sh

# Desplegar desde cero
./scripts/deploy.sh

# Verificar estado
./scripts/check-status.sh

# Probar ejercicios básicos
ssh alumno@192.16.0.10
```

## 📚 Recursos

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Markdown Guide](https://www.markdownguide.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [ShellCheck](https://www.shellcheck.net/)

## ❓ Preguntas

Si tienes preguntas:

1. Revisa la [documentación](docs/)
2. Busca en [Issues cerrados](https://github.com/AdrianCE94/ssh-pivoting-lab/issues?q=is%3Aissue+is%3Aclosed)
3. Abre un nuevo Issue con la etiqueta `question`

## 🎓 Para Educadores

Si eres instructor y quieres contribuir con:

- Planes de lección
- Rúbricas de evaluación
- Casos de estudio
- Material didáctico adicional

Por favor, contacta mediante Issue o PR.

---

**¡Gracias por contribuir a la comunidad de hacking ético! 🚀🔐**