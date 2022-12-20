/**
 * @description: 判断关键词是否符合匹配规则
 * @param {string} keyword 关键字
 * @return {boolean} 是否是关键字
 */
export const judgeKeyword = (keyword) => {
    /**
     * 判断关键词是否符合天气查询规则, 且以 # 开头
     */
    const weatherReg = /^#(.*)天气(.*)$/;
    return weatherReg.test(keyword);
}