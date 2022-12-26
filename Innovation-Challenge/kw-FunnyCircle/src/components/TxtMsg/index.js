import s from "./index.module.less";
import React, { memo } from "react";
import { renderTxt } from "@/utils/common";

const TxtMsg = (props) => {
  const { message } = props;
  const { self } = props;
  return (
    <div className={s.main}>
      <div className={self ? s.righttxt : s.lefttxt}>{renderTxt(message.msg)}</div>
    </div>
  );
};

export default memo(TxtMsg);
