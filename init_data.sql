-- ============================================================
-- 笔记工坊 AI 读书笔记管理系统 - 初始数据脚本 (MySQL 8.x)
-- 使用：mysql -u root -p < init_data.sql   （请在 schema.sql 之后执行）
-- 作用：创建可直接登录的初始账号：1 个管理员 + 2 个普通用户
-- 说明：密码均为 BCrypt 密文（由项目同款 spring-security-crypto 生成），
--       与明文一一对应，导入后即可用明文密码登录。
-- 幂等：基于 username 唯一键使用 INSERT IGNORE，
--       账号已存在时不会重复插入、也不会覆盖原密码，可安全重复执行。
-- ============================================================

USE note_workshop;

INSERT IGNORE INTO `user`
    (username, password, nickname, avatar, role, status, deleted)
VALUES
    -- 管理员：admin / Admin@2026
    ('admin',
     '$2a$10$QDt7Ey42n2RwCbbCw3noTOf/9HQWtbaj9ZajBnmFqOhXNUcuWoMCC',
     '管理员', '', 'ADMIN', 1, 0),

    -- 普通用户：User / test
    ('User',
     '$2a$10$iiRANNrxZEff.q8z94.O/eH.O4rzJq/MTPOFcI9.WOYvpPdiKGRK6',
     '用户一', '', 'USER', 1, 0),

    -- 普通用户：student01 / 123456
    ('student01',
     '$2a$10$SI.O.nrAn18cJH0BIsbf1ebiNm.2cFZ3qvX7Nw9aOOTiEU9EQO8hK',
     '同学一', '', 'USER', 1, 0);
