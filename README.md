# 笔记工坊 AI 读书笔记管理系统（Note-Workshop）

面向在校学生的读书笔记社区，前后端分离的单体 Web 应用。用户注册登录后，可发布读书笔记（支持多图上传）、浏览公开笔记、点赞；管理员可在后台审核笔记、管理用户账号。

> 说明：项目名中的“AI”为预留方向，当前**未接入任何真实大模型**，仅建好了相关数据表（详见“已知边界”一节）。请以本文档所述实际功能为准。

## 功能概览

| 分类 | 功能 | 状态 |
|------|------|------|
| 基础 | 注册 / 登录（JWT 鉴权） | ✅ 已实现 |
| 基础 | 笔记发布 / 公开列表 / 我的笔记 / 详情 / 删除（多图上传） | ✅ 已实现 |
| 基础 | 点赞 / 取消点赞 / 我赞过的列表 | ✅ 已实现 |
| 基础 | 个人资料修改 / 头像上传 | ✅ 已实现 |
| 进阶 | 管理员后台：用户列表、启用/禁用用户 | ✅ 已实现 |
| 进阶 | 管理员后台：笔记列表、审核通过 / 驳回 | ✅ 已实现 |
| AI | AI 阅读助手 / 智能客服 | ❌ 未实现（仅建预留表） |
| 社交 | 关注（follow）、评论（comment） | ❌ 未实现（仅建预留表） |

## 技术栈

| 层 | 技术 | 版本 |
|----|------|------|
| 后端 | Java | 25（JDK 17+ 可编译运行） |
| 后端 | Spring Boot | 3.5.16 |
| ORM | MyBatis-Plus | 3.5.17（含分页插件独立包） |
| 鉴权 | JWT（jjwt） | 0.12.7 |
| 密码加密 | spring-security-crypto（BCrypt） | Spring Boot 托管版本 |
| 数据库 | MySQL | 8.x |
| 构建 | Maven | 3.9.x |
| 代码简化 | Lombok | 1.18.48（兼容 JDK 25） |
| 前端 | 原生 HTML / CSS / JavaScript（SPA 单页应用） | — |

## 环境要求

- JDK 17+（本机验证环境为 JDK 25）
- Maven 3.9+
- MySQL 8.x
- 现代浏览器（Chrome / Edge 等）
- IDE 可选：IntelliJ IDEA / VS Code（非必需，可用命令行）

## 目录结构

```
note-workshop
├── pom.xml                         # Maven 依赖与构建配置
├── sql/schema.sql                  # 建库建表脚本（不含账号数据）
├── upload/                         # 运行时生成的本地上传文件目录
└── src/main
    ├── java/com/noteworkshop
    │   ├── NoteWorkshopApplication.java   # Spring Boot 启动类
    │   ├── common/                 # 统一返回 Result、业务异常、全局异常处理
    │   ├── config/                 # MyBatis-Plus 分页、字段填充、Web 配置
    │   ├── security/               # JwtUtil、JwtInterceptor、UserContext
    │   ├── controller/             # REST 接口：Auth/Note/Like/User/Admin
    │   ├── service/                # 业务逻辑（接口 + impl）
    │   ├── mapper/                 # MyBatis-Plus Mapper
    │   ├── entity/                 # 实体：User/Note/NoteImage/NoteLike/NoteAudit
    │   ├── dto/                    # 请求/响应对象
    │   └── util/                   # 文件上传工具
    └── resources
        ├── application.yml         # 应用配置（端口/数据库/上传/JWT）
        └── static                  # 前端静态页面
            ├── index.html          # 页面骨架（7 个视图）
            ├── css/style.css       # 样式
            └── js/api.js、js/app.js # 接口封装与页面逻辑
```

## 快速上手

### 1. 建库建表

在 MySQL 命令行执行（脚本自带建库与建表，无需手动建库）：

```bash
mysql -u root -p < sql/schema.sql
```

> 注意：该脚本**只建表，不包含任何账号数据**（管理员账号的 INSERT 在脚本中被注释）。

### 2. 配置数据库连接

默认连接本机：`localhost:3306`，库名 `note_workshop`，用户名 `root`，密码 `Z20261009`（见 `application.yml`）。

若你的数据库密码不同，二选一：

- 直接改 `src/main/resources/application.yml` 里的 `spring.datasource.password`；
- 或用环境变量覆盖（不改文件）：
  `DB_HOST` / `DB_PORT` / `DB_NAME` / `DB_USERNAME` / `DB_PASSWORD`

### 3. 启动后端

```bash
mvn spring-boot:run
```

如果 `mvn` 未加入系统 PATH，改用 Maven 安装目录下的完整路径（Windows 示例）：

```powershell
& "D:\learn\maven\apache-maven-3.9.16\bin\mvn.cmd" spring-boot:run
```

或使用 IDEA：打开项目，直接运行 `NoteWorkshopApplication`。

### 4. 访问

浏览器打开：`http://localhost:8080`（端口可在 `application.yml` 的 `server.port` 修改）。

## 账号说明

已提供初始数据脚本 `sql/init_data.sql`，导入后自动创建以下**可直接登录**的账号（密码为 BCrypt 密文，与项目一致）：

| 用户名 | 密码 | 角色 | 状态 |
|--------|------|------|------|
| admin | `Admin@2026` | ADMIN（管理员） | 启用 |
| User | `test` | USER | 启用 |
| student01 | `123456` | USER | 启用 |

导入方式（请在 `schema.sql` 建表之后执行）：

```bash
mysql -u root -p < sql/init_data.sql
```

说明：

- 脚本基于 `username` 唯一键使用 `INSERT IGNORE`，**账号已存在时不会重复插入或覆盖密码**，可安全重复执行。
- `schema.sql` 本身只建表、不含任何账号。若不用该脚本，也可打开页面自行注册普通用户，再把某账号的 `role` 改为 `'ADMIN'` 来成为管理员。

## 接口一览

鉴权规则：除 `/api/auth/**`（注册/登录）与 `/files/**`（上传文件访问）外，其余 `/api/**` 接口均需在请求头携带 `Authorization: Bearer <token>`；管理员接口额外校验 `ADMIN` 角色。

### 认证

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/auth/register` | 注册 |
| POST | `/api/auth/login` | 登录，返回 JWT |

### 用户

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/user/me` | 当前用户信息 |
| PUT | `/api/user/profile` | 修改资料 |
| POST | `/api/user/avatar` | 上传头像 |

### 笔记

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/note` | 新建笔记（multipart/form-data，字段 `data`=JSON、`images`=可选多图） |
| GET | `/api/note/public` | 公开笔记分页（参数 `page`、`size`） |
| GET | `/api/note/my` | 我的笔记分页 |
| GET | `/api/note/{id}` | 笔记详情 |
| DELETE | `/api/note/{id}` | 删除笔记（仅作者本人） |

### 点赞

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/note/{id}/like` | 点赞 |
| DELETE | `/api/note/{id}/like` | 取消点赞 |
| GET | `/api/note/liked` | 我赞过的列表 |

### 管理员

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/admin/users` | 用户列表 |
| PUT | `/api/admin/user/{id}/status` | 启用 / 禁用用户 |
| GET | `/api/admin/notes` | 笔记列表（含审核状态） |
| PUT | `/api/admin/note/{id}/audit` | 审核笔记（通过 / 驳回） |

## 配置项

在 `application.yml` 中，均可用环境变量覆盖：

| 配置 | 默认值 | 环境变量 |
|------|--------|----------|
| 服务端口 | `8080` | — |
| 数据库地址 | `localhost:3306` | `DB_HOST` / `DB_PORT` |
| 数据库名 | `note_workshop` | `DB_NAME` |
| 数据库账号 | `root` / `Z20261009` | `DB_USERNAME` / `DB_PASSWORD` |
| 上传目录 | `D:/learn/note-workshop/upload` | `UPLOAD_DIR` |
| JWT 密钥 | 见 application.yml（生产请务必覆盖） | `JWT_SECRET` |
| JWT 有效期 | `72` 小时 | — |
| 单文件大小上限 | `10MB` / 请求 `20MB` | — |

## 数据库表（11 张）

- 核心业务：`user`、`note`、`note_image`
- 互动社交：`note_like`、`follow`、`comment`、`note_audit`
- AI 预留：`ai_result`、`ai_session`、`ai_message`、`ai_log`

## 已知边界与未实现项（如实说明）

- **AI 相关**：`ai_result`、`ai_session`、`ai_message`、`ai_log` 四张表已建，但后端**没有** AI 调用代码，也未接入任何大模型；“AI 摘要”目前是预留状态。
- **关注 / 评论**：`follow`、`comment` 表已建，但后端无对应接口，前端也无对应入口。
- **前端**：为原生 SPA，功能与后端已实现接口打通；未实现部分（关注、评论、AI）在页面中无入口。
- **账号数据**：建表脚本不含账号，需按上文自行初始化。

## 常见问题

- **启动报数据库连接失败**：检查 MySQL 服务是否启动、`application.yml` 密码是否正确，或用环境变量覆盖。
- **中文乱码**：确认连接串包含 `characterEncoding=utf8`（application.yml 已默认带）。
- **上传的文件打不开**：确认 `upload.dir` 目录存在且有写权限。
