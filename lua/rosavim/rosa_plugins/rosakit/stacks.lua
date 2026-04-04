--- Rosakit - Stack definitions
--- Each stack defines: detect(), sections, lsp_actions
local M = {}

--- @class RosakitSection
--- @field label string
--- @field dirs string[]
--- @field patterns string[]|nil
--- @field icon string

--- @class RosakitStack
--- @field name string
--- @field icon string
--- @field detect fun(root: string): boolean
--- @field sections RosakitSection[]
--- @field lsp_tools { label: string, cmd: string, icon: string }[]|nil

local function has_file(root, file)
  return vim.fn.filereadable(root .. '/' .. file) == 1
end

local function has_dir(root, dir)
  return vim.fn.isdirectory(root .. '/' .. dir) == 1
end

local function pkg_has(root, dep)
  local pkg = root .. '/package.json'
  if vim.fn.filereadable(pkg) == 0 then
    return false
  end
  local ok, lines = pcall(vim.fn.readfile, pkg)
  if not ok then
    return false
  end
  local content = table.concat(lines, '\n')
  return content:find('"' .. dep:gsub('([%.%-%+%[%]%(%)%$%^%%])', '%%%1') .. '"') ~= nil
end

-- ── React ────────────────────────────────────────────────────────────

M.react = {
  name = 'React',
  icon = ' ',
  detect = function(root)
    return pkg_has(root, 'react') and not pkg_has(root, 'next')
  end,
  sections = {
    { label = 'Find Components', dirs = { 'src/components', 'components', 'app/components' }, icon = '󰡀' },
    { label = 'Pages', dirs = { 'src/pages', 'pages', 'src/views', 'src/routes' }, icon = '' },
    { label = 'Hooks', dirs = { 'src/hooks', 'hooks' }, icon = '󰛢' },
    { label = 'Context / Store', dirs = { 'src/context', 'src/store', 'src/state', 'src/redux', 'src/zustand' }, icon = '󱁉' },
    { label = 'Services / API', dirs = { 'src/services', 'src/api', 'src/lib', 'src/utils/api' }, icon = '󰒍' },
    { label = 'Utils', dirs = { 'src/utils', 'src/helpers', 'src/lib' }, icon = '' },
    { label = 'Types', dirs = { 'src/types', 'src/@types', 'src/interfaces' }, icon = '' },
    { label = 'Styles', dirs = { 'src/styles', 'src/css', 'styles' }, icon = '' },
    { label = 'Find Tests', dirs = { 'src/__tests__', '__tests__', 'tests', 'test' }, icon = '󰙨' },
    { label = 'Find Config', dirs = { '.' }, patterns = { '*.config.*', '.eslintrc*', 'tsconfig*' }, icon = '' },
  },
}

-- ── Next.js ──────────────────────────────────────────────────────────

M.nextjs = {
  name = 'Next.js',
  icon = '󰰓 ',
  detect = function(root)
    return pkg_has(root, 'next')
  end,
  sections = {
    { label = 'Find Components', dirs = { 'src/components', 'components', 'app/components' }, icon = '󰡀' },
    { label = 'App Routes', dirs = { 'app', 'src/app' }, icon = '' },
    { label = 'Pages', dirs = { 'pages', 'src/pages' }, icon = '' },
    { label = 'API Routes', dirs = { 'app/api', 'pages/api', 'src/app/api' }, icon = '󰒍' },
    { label = 'Hooks', dirs = { 'src/hooks', 'hooks' }, icon = '󰛢' },
    { label = 'Context / Store', dirs = { 'src/context', 'src/store', 'src/state' }, icon = '󱁉' },
    { label = 'Find Services', dirs = { 'src/services', 'src/lib', 'src/api', 'lib' }, icon = '󰒍' },
    { label = 'Utils', dirs = { 'src/utils', 'src/helpers', 'utils', 'lib' }, icon = '' },
    { label = 'Types', dirs = { 'src/types', 'src/@types', 'types' }, icon = '' },
    { label = 'Find Middleware', dirs = { '.' }, patterns = { 'middleware.*' }, icon = '󰒃' },
    { label = 'Styles', dirs = { 'src/styles', 'styles' }, icon = '' },
    { label = 'Find Tests', dirs = { 'src/__tests__', '__tests__', 'tests', 'test' }, icon = '󰙨' },
    { label = 'Find Config', dirs = { '.' }, patterns = { 'next.config.*', 'tailwind.config.*', 'tsconfig*' }, icon = '' },
  },
}

-- ── Vue ──────────────────────────────────────────────────────────────

M.vue = {
  name = 'Vue',
  icon = '󰡄 ',
  detect = function(root)
    return pkg_has(root, 'vue')
  end,
  sections = {
    { label = 'Find Components', dirs = { 'src/components', 'components' }, icon = '󰡀' },
    { label = 'Views / Pages', dirs = { 'src/views', 'src/pages', 'pages' }, icon = '' },
    { label = 'Composables', dirs = { 'src/composables', 'src/hooks' }, icon = '󰛢' },
    { label = 'Store', dirs = { 'src/store', 'src/stores', 'src/pinia' }, icon = '󱁉' },
    { label = 'Services / API', dirs = { 'src/services', 'src/api', 'src/lib' }, icon = '󰒍' },
    { label = 'Router', dirs = { 'src/router' }, icon = '' },
    { label = 'Utils', dirs = { 'src/utils', 'src/helpers' }, icon = '' },
    { label = 'Types', dirs = { 'src/types' }, icon = '' },
    { label = 'Styles', dirs = { 'src/styles', 'src/assets/styles' }, icon = '' },
    { label = 'Find Tests', dirs = { 'src/__tests__', 'tests', 'test' }, icon = '󰙨' },
  },
}

-- ── Angular ──────────────────────────────────────────────────────────

M.angular = {
  name = 'Angular',
  icon = ' ',
  detect = function(root)
    return pkg_has(root, '@angular/core')
  end,
  sections = {
    { label = 'Find Components', dirs = { 'src/app/components', 'src/app' }, patterns = { '*.component.ts' }, icon = '󰡀' },
    { label = 'Find Services', dirs = { 'src/app/services', 'src/app' }, patterns = { '*.service.ts' }, icon = '󰒍' },
    { label = 'Modules', dirs = { 'src/app' }, patterns = { '*.module.ts' }, icon = '' },
    { label = 'Guards', dirs = { 'src/app/guards', 'src/app' }, patterns = { '*.guard.ts' }, icon = '󰒃' },
    { label = 'Pipes', dirs = { 'src/app/pipes', 'src/app' }, patterns = { '*.pipe.ts' }, icon = '' },
    { label = 'Directives', dirs = { 'src/app/directives', 'src/app' }, patterns = { '*.directive.ts' }, icon = '󰛢' },
    { label = 'Find Models', dirs = { 'src/app/models', 'src/app/interfaces' }, icon = '' },
    { label = 'Find Tests', dirs = { 'src' }, patterns = { '*.spec.ts' }, icon = '󰙨' },
  },
}

-- ── Svelte ───────────────────────────────────────────────────────────

M.svelte = {
  name = 'Svelte',
  icon = ' ',
  detect = function(root)
    return pkg_has(root, 'svelte') or pkg_has(root, '@sveltejs/kit')
  end,
  sections = {
    { label = 'Find Components', dirs = { 'src/lib/components', 'src/components' }, icon = '󰡀' },
    { label = 'Find Routes', dirs = { 'src/routes' }, icon = '' },
    { label = 'Lib', dirs = { 'src/lib' }, icon = '' },
    { label = 'Stores', dirs = { 'src/lib/stores', 'src/stores' }, icon = '󱁉' },
    { label = 'Utils', dirs = { 'src/lib/utils', 'src/utils' }, icon = '' },
    { label = 'Types', dirs = { 'src/lib/types', 'src/types' }, icon = '' },
    { label = 'Find Tests', dirs = { 'tests', 'test', 'src/__tests__' }, icon = '󰙨' },
  },
}

-- ── Nest.js ──────────────────────────────────────────────────────────

M.nestjs = {
  name = 'Nest.js',
  icon = '󰰓 ',
  detect = function(root)
    return pkg_has(root, '@nestjs/core')
  end,
  sections = {
    { label = 'Modules', dirs = { 'src' }, patterns = { '*.module.ts' }, icon = '' },
    { label = 'Find Controllers', dirs = { 'src' }, patterns = { '*.controller.ts' }, icon = '󰒍' },
    { label = 'Find Services', dirs = { 'src' }, patterns = { '*.service.ts' }, icon = '' },
    { label = 'Guards', dirs = { 'src' }, patterns = { '*.guard.ts' }, icon = '󰒃' },
    { label = 'Find Middleware', dirs = { 'src' }, patterns = { '*.middleware.ts' }, icon = '󰒃' },
    { label = 'DTOs', dirs = { 'src' }, patterns = { '*.dto.ts' }, icon = '' },
    { label = 'Entities', dirs = { 'src' }, patterns = { '*.entity.ts' }, icon = '' },
    { label = 'Pipes', dirs = { 'src' }, patterns = { '*.pipe.ts' }, icon = '' },
    { label = 'Interceptors', dirs = { 'src' }, patterns = { '*.interceptor.ts' }, icon = '󰛢' },
    { label = 'Decorators', dirs = { 'src' }, patterns = { '*.decorator.ts' }, icon = '' },
    { label = 'Find Config', dirs = { 'src/config', 'config' }, icon = '' },
    { label = 'Find Tests', dirs = { 'src', 'test' }, patterns = { '*.spec.ts', '*.e2e-spec.ts' }, icon = '󰙨' },
  },
}

-- ── Express ──────────────────────────────────────────────────────────

M.express = {
  name = 'Express',
  icon = '󰰓 ',
  detect = function(root)
    return pkg_has(root, 'express') and not pkg_has(root, '@nestjs/core')
  end,
  sections = {
    { label = 'Find Routes', dirs = { 'src/routes', 'routes' }, icon = '' },
    { label = 'Find Controllers', dirs = { 'src/controllers', 'controllers' }, icon = '󰒍' },
    { label = 'Find Middleware', dirs = { 'src/middleware', 'middleware', 'src/middlewares' }, icon = '󰒃' },
    { label = 'Find Models', dirs = { 'src/models', 'models' }, icon = '' },
    { label = 'Find Services', dirs = { 'src/services', 'services' }, icon = '' },
    { label = 'Find Config', dirs = { 'src/config', 'config' }, icon = '' },
    { label = 'Utils', dirs = { 'src/utils', 'utils', 'src/helpers' }, icon = '' },
    { label = 'Find Tests', dirs = { 'tests', 'test', '__tests__' }, icon = '󰙨' },
  },
}

-- ── Go ───────────────────────────────────────────────────────────────

M.go = {
  name = 'Go',
  icon = ' ',
  detect = function(root)
    return has_file(root, 'go.mod')
  end,
  sections = {
    { label = 'Find Handlers', dirs = { 'handler', 'handlers', 'internal/handler', 'internal/handlers', 'api', 'api/handler' }, icon = '󰒍' },
    { label = 'Find Models', dirs = { 'model', 'models', 'internal/model', 'internal/models', 'entity', 'domain' }, icon = '' },
    { label = 'Find Services', dirs = { 'service', 'services', 'internal/service', 'internal/services', 'usecase' }, icon = '' },
    { label = 'Find Repository', dirs = { 'repository', 'repositories', 'internal/repository', 'internal/repositories', 'store' }, icon = '' },
    { label = 'Find Middleware', dirs = { 'middleware', 'internal/middleware' }, icon = '󰒃' },
    { label = 'Find Routes', dirs = { 'router', 'routes', 'internal/router' }, icon = '' },
    { label = 'Find Config', dirs = { 'config', 'internal/config', 'pkg/config' }, icon = '' },
    { label = 'Cmd', dirs = { 'cmd' }, icon = '' },
    { label = 'Internal', dirs = { 'internal' }, icon = '' },
    { label = 'Pkg', dirs = { 'pkg' }, icon = '' },
    { label = 'Find Tests', dirs = { '.' }, patterns = { '*_test.go' }, icon = '󰙨' },
  },
  lsp_tools = {
    { label = 'Generate Test', cmd = 'GoAddTest', icon = '󰙨' },
    { label = 'Generate All Tests', cmd = 'GoAddAllTest', icon = '󰙨' },
    { label = 'Fill Struct', cmd = 'GoFillStruct', icon = '' },
    { label = 'Add Tags', cmd = 'GoAddTag', icon = '' },
    { label = 'Remove Tags', cmd = 'GoRmTag', icon = '' },
    { label = 'Impl Interface', cmd = 'GoImpl', icon = '' },
    { label = 'Tidy', cmd = '!go mod tidy', icon = '' },
  },
}

-- ── Python / Django ──────────────────────────────────────────────────

M.django = {
  name = 'Django',
  icon = ' ',
  detect = function(root)
    return has_file(root, 'manage.py')
  end,
  sections = {
    { label = 'Views', dirs = { '.' }, patterns = { '**/views.py', '**/views/' }, icon = '' },
    { label = 'Find Models', dirs = { '.' }, patterns = { '**/models.py', '**/models/' }, icon = '' },
    { label = 'Serializers', dirs = { '.' }, patterns = { '**/serializers.py', '**/serializers/' }, icon = '' },
    { label = 'URLs', dirs = { '.' }, patterns = { '**/urls.py' }, icon = '' },
    { label = 'Admin', dirs = { '.' }, patterns = { '**/admin.py' }, icon = '' },
    { label = 'Forms', dirs = { '.' }, patterns = { '**/forms.py' }, icon = '' },
    { label = 'Templates', dirs = { 'templates', '**/templates' }, icon = '' },
    { label = 'Migrations', dirs = { '.' }, patterns = { '**/migrations/*.py' }, icon = '' },
    { label = 'Management', dirs = { '.' }, patterns = { '**/management/commands/*.py' }, icon = '' },
    { label = 'Find Tests', dirs = { '.' }, patterns = { '**/test_*.py', '**/*_test.py', '**/tests.py' }, icon = '󰙨' },
    { label = 'Find Config', dirs = { '.' }, patterns = { '**/settings.py', '**/settings/' }, icon = '' },
  },
}

-- ── Python / FastAPI ─────────────────────────────────────────────────

M.fastapi = {
  name = 'FastAPI',
  icon = ' ',
  detect = function(root)
    return (has_file(root, 'requirements.txt') or has_file(root, 'pyproject.toml'))
      and not has_file(root, 'manage.py')
      and (has_dir(root, 'app') or has_dir(root, 'src'))
  end,
  sections = {
    { label = 'Routes / Endpoints', dirs = { 'app/routes', 'app/api', 'src/routes', 'src/api', 'app/routers' }, icon = '󰒍' },
    { label = 'Find Models', dirs = { 'app/models', 'src/models' }, icon = '' },
    { label = 'Schemas', dirs = { 'app/schemas', 'src/schemas' }, icon = '' },
    { label = 'Find Services', dirs = { 'app/services', 'src/services' }, icon = '' },
    { label = 'Find Config', dirs = { 'app/config', 'src/config', 'app/core' }, icon = '' },
    { label = 'Utils', dirs = { 'app/utils', 'src/utils' }, icon = '' },
    { label = 'Find Tests', dirs = { 'tests', 'test' }, icon = '󰙨' },
  },
}

-- ── PHP / Laravel ────────────────────────────────────────────────────

M.laravel = {
  name = 'Laravel',
  icon = ' ',
  detect = function(root)
    return has_file(root, 'artisan')
  end,
  sections = {
    { label = 'Find Controllers', dirs = { 'app/Http/Controllers' }, icon = '󰒍' },
    { label = 'Find Models', dirs = { 'app/Models' }, icon = '' },
    { label = 'Find Routes', dirs = { 'routes' }, icon = '' },
    { label = 'Views', dirs = { 'resources/views' }, icon = '' },
    { label = 'Migrations', dirs = { 'database/migrations' }, icon = '' },
    { label = 'Find Middleware', dirs = { 'app/Http/Middleware' }, icon = '󰒃' },
    { label = 'Find Services', dirs = { 'app/Services' }, icon = '' },
    { label = 'Requests', dirs = { 'app/Http/Requests' }, icon = '' },
    { label = 'Resources', dirs = { 'app/Http/Resources' }, icon = '' },
    { label = 'Events', dirs = { 'app/Events' }, icon = '' },
    { label = 'Jobs', dirs = { 'app/Jobs' }, icon = '' },
    { label = 'Providers', dirs = { 'app/Providers' }, icon = '' },
    { label = 'Find Config', dirs = { 'config' }, icon = '' },
    { label = 'Find Tests', dirs = { 'tests' }, icon = '󰙨' },
  },
}

-- ── Java / Spring ────────────────────────────────────────────────────

M.spring = {
  name = 'Spring',
  icon = ' ',
  detect = function(root)
    return (has_file(root, 'build.gradle') or has_file(root, 'build.gradle.kts') or has_file(root, 'pom.xml'))
      and (has_dir(root, 'src/main/java') or has_dir(root, 'src/main/kotlin'))
  end,
  sections = {
    { label = 'Find Controllers', dirs = { 'src/main' }, patterns = { '**/*Controller.java', '**/*Controller.kt' }, icon = '󰒍' },
    { label = 'Find Services', dirs = { 'src/main' }, patterns = { '**/*Service.java', '**/*ServiceImpl.java', '**/*Service.kt' }, icon = '' },
    { label = 'Repositories', dirs = { 'src/main' }, patterns = { '**/*Repository.java', '**/*Repository.kt' }, icon = '' },
    { label = 'Entities', dirs = { 'src/main' }, patterns = { '**/*Entity.java', '**/*Entity.kt' }, icon = '' },
    { label = 'DTOs', dirs = { 'src/main' }, patterns = { '**/*DTO.java', '**/*Dto.java', '**/*Request.java', '**/*Response.java' }, icon = '' },
    { label = 'Find Config', dirs = { 'src/main' }, patterns = { '**/*Config.java', '**/*Configuration.java' }, icon = '' },
    { label = 'Exceptions', dirs = { 'src/main' }, patterns = { '**/*Exception.java' }, icon = '' },
    { label = 'Find Tests', dirs = { 'src/test' }, icon = '󰙨' },
    { label = 'Resources', dirs = { 'src/main/resources' }, icon = '' },
  },
}

--- All stacks in detection priority order
M.all = {
  M.nextjs,
  M.nestjs,
  M.angular,
  M.svelte,
  M.vue,
  M.react,
  M.express,
  M.laravel,
  M.django,
  M.fastapi,
  M.spring,
  M.go,
}

--- Detect all stacks in a given root directory
--- @param root string
--- @return RosakitStack[]
function M.detect(root)
  local found = {}
  for _, stack in ipairs(M.all) do
    local ok, detected = pcall(stack.detect, root)
    if ok and detected then
      table.insert(found, stack)
    end
  end
  return found
end

--- Detect stacks in monorepo (scan subdirectories)
--- @param root string
--- @return { root: string, stack: RosakitStack }[]
function M.detect_workspaces(root)
  local workspaces = {}

  -- Check root first
  local root_stacks = M.detect(root)
  for _, stack in ipairs(root_stacks) do
    table.insert(workspaces, { root = root, stack = stack })
  end

  -- Scan common monorepo dirs
  local mono_dirs = { 'apps', 'packages', 'services', 'libs', 'modules' }
  for _, mono in ipairs(mono_dirs) do
    local mono_path = root .. '/' .. mono
    if has_dir(root, mono) then
      local entries = vim.fn.readdir(mono_path)
      for _, entry in ipairs(entries) do
        local sub = mono_path .. '/' .. entry
        if vim.fn.isdirectory(sub) == 1 then
          local sub_stacks = M.detect(sub)
          for _, stack in ipairs(sub_stacks) do
            table.insert(workspaces, { root = sub, stack = stack })
          end
        end
      end
    end
  end

  return workspaces
end

return M
