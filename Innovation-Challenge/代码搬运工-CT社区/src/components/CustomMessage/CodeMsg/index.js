import React, { memo } from "react";
import s from "./index.module.less";
import Prismjs from 'prismjs'

// 自定义消息——卡片消息
const CardMsg = (props) => {
  const { message } = props;
  const {codeLang, codeContent} = message.customExts ?? {};

  const highlightCode = Prismjs.highlight(codeContent, Prismjs.languages[`${codeLang}`], codeLang)
  function createMarkup(html) { 
    return {__html: html};
  };

  return (
    <pre className={s.code} dangerouslySetInnerHTML={createMarkup(highlightCode)} />
  );
};

export default memo(CardMsg);
