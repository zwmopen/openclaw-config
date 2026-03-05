#!/usr/bin/env node
/**
 * 生财有术日报抓取脚本
 * 
 * 功能：
 * 1. 打开生财有术网站
 * 2. 抓取热门帖子
 * 3. 生成日报格式
 * 4. 返回日报内容
 * 
 * 使用：
 * node scys-daily.js [--weekly]
 */

const SCYS_URL = "https://scys.com";

// 日报生成函数
function generateDailyReport(posts) {
  const date = new Date().toLocaleDateString('zh-CN', { 
    year: 'numeric', 
    month: '2-digit', 
    day: '2-digit' 
  });
  
  let report = `## 📰 生财有术日报 - ${date}\n\n`;
  report += `### 🔥 今日热门\n\n`;
  
  posts.forEach((post, index) => {
    report += `**${index + 1}. ${post.title}**\n`;
    report += `👤 ${post.author} | 👍${post.likes} 💬${post.comments} | 🏷️ ${post.tags.join('、')}\n`;
    report += `🔗 ${post.url}\n`;
    if (post.summary) {
      report += `📝 ${post.summary}\n`;
    }
    report += `\n`;
  });
  
  report += `---\n`;
  report += `💡 由 OpenClaw 自动抓取推送 | 📅 ${date}\n`;
  
  return report;
}

// 周报生成函数
function generateWeeklyReport(posts) {
  const date = new Date().toLocaleDateString('zh-CN', { 
    year: 'numeric', 
    month: '2-digit', 
    day: '2-digit' 
  });
  
  let report = `## 📰 生财有术周报 - ${date}\n\n`;
  report += `### ⭐ 本周精华\n\n`;
  
  posts.forEach((post, index) => {
    report += `**${index + 1}. ${post.title}**\n`;
    report += `👤 ${post.author} | 👍${post.likes} 💬${post.comments} | 🏷️ ${post.tags.join('、')}\n`;
    report += `🔗 ${post.url}\n`;
    if (post.summary) {
      report += `📝 ${post.summary}\n`;
    }
    report += `\n`;
  });
  
  report += `---\n`;
  report += `💡 由 OpenClaw 自动抓取推送 | 📅 ${date}\n`;
  
  return report;
}

// 导出函数供 OpenClaw 调用
module.exports = {
  generateDailyReport,
  generateWeeklyReport,
  SCYS_URL
};

// 如果直接运行，输出示例
if (require.main === module) {
  const examplePosts = [
    {
      title: "AI亿万俱乐部，token日耗过亿的富豪快来交流",
      author: "亦仁(星主)",
      likes: 376,
      comments: 7,
      tags: ["AI", "官方活动"],
      url: "https://scys.com/posts/example",
      summary: "准备建个群，AI亿万俱乐部，token每天消耗一亿以上的来交流"
    },
    {
      title: "告别玩具级AI，小龙虾在飞书打工实录",
      author: "刘小排",
      likes: 163,
      comments: 16,
      tags: ["AI", "OpenClaw"],
      url: "https://scys.com/posts/example2",
      summary: "分享OpenClaw在飞书体系内的11个真实应用案例"
    }
  ];
  
  const isWeekly = process.argv.includes('--weekly');
  const report = isWeekly 
    ? generateWeeklyReport(examplePosts) 
    : generateDailyReport(examplePosts);
  
  console.log(report);
}
