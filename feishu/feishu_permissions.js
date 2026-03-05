// =====================================================
// 飞书开放平台 - 批量添加权限脚本
// =====================================================
// 使用方法：
// 1. 打开飞书开放平台：https://open.feishu.cn/
// 2. 进入您的应用 -> 权限管理
// 3. 打开浏览器开发者工具（F12）
// 4. 切换到 Console（控制台）标签
// 5. 复制并粘贴此脚本，按回车执行
// 6. 等待脚本自动添加所有权限
// =====================================================

(async function() {
    console.log('🚀 开始批量添加飞书权限...');
    
    // 必需权限列表
    const requiredPermissions = [
        // 消息相关权限
        'im:message',                    // 获取与发送单聊、群组消息
        'im:message:send_as_bot',        // 以应用身份发消息
        'im:message:receive_as_bot',     // 接收群聊中@机器人消息
        'im:chat',                       // 获取群组信息
        'im:chat:readonly',              // 获取群组信息（只读）
        
        // 用户相关权限
        'contact:user.base:readonly',    // 获取用户基本信息
        'contact:user.employee_id:readonly', // 获取用户员工ID
        
        // 群组相关权限
        'im:chat.member:readonly',       // 获取群成员列表
        
        // 可选权限（增强功能）
        'im:resource',                   // 获取与上传图片或文件资源
        'im:meeting:readonly',           // 获取会议信息
        'calendar:calendar:readonly'     // 获取日历信息
    ];
    
    // 延迟函数
    const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));
    
    // 模拟点击权限项
    const clickPermission = async (permission) => {
        try {
            // 查找权限搜索框
            const searchInput = document.querySelector('input[placeholder*="搜索"]') || 
                               document.querySelector('input[type="text"]');
            
            if (searchInput) {
                // 清空搜索框
                searchInput.value = '';
                searchInput.dispatchEvent(new Event('input', { bubbles: true }));
                await delay(300);
                
                // 输入权限名称
                searchInput.value = permission;
                searchInput.dispatchEvent(new Event('input', { bubbles: true }));
                await delay(500);
                
                // 查找添加按钮
                const addButton = document.querySelector('button[class*="add"]') ||
                                 document.querySelector('span[class*="add"]') ||
                                 Array.from(document.querySelectorAll('button')).find(btn => 
                                     btn.textContent.includes('添加') || 
                                     btn.textContent.includes('申请')
                                 );
                
                if (addButton) {
                    addButton.click();
                    console.log(`✅ 已添加权限: ${permission}`);
                    await delay(500);
                    return true;
                } else {
                    console.log(`⚠️ 未找到添加按钮: ${permission}`);
                    return false;
                }
            } else {
                console.log('❌ 未找到搜索框，请确保在权限管理页面');
                return false;
            }
        } catch (error) {
            console.error(`❌ 添加权限失败 ${permission}:`, error);
            return false;
        }
    };
    
    // 批量添加权限
    let successCount = 0;
    let failCount = 0;
    
    for (const permission of requiredPermissions) {
        const result = await clickPermission(permission);
        if (result) {
            successCount++;
        } else {
            failCount++;
        }
        await delay(800); // 每次操作间隔800ms
    }
    
    console.log('====================================');
    console.log(`✅ 成功添加: ${successCount} 个权限`);
    console.log(`❌ 添加失败: ${failCount} 个权限`);
    console.log('====================================');
    console.log('💡 提示: 部分权限可能需要管理员审批');
    console.log('💡 提示: 请检查权限列表，确认所有权限已添加');
    
    // 显示权限详情
    console.log('\n📋 已添加的权限列表:');
    requiredPermissions.forEach((perm, index) => {
        console.log(`${index + 1}. ${perm}`);
    });
    
    // 提醒用户
    alert(`权限添加完成！\n\n成功: ${successCount} 个\n失败: ${failCount} 个\n\n请检查权限列表，确认所有权限已添加。\n部分权限可能需要管理员审批。`);
})();
