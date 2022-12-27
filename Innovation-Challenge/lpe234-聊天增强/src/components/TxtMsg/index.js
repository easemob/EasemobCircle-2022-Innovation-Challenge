import s from "./index.module.less";
import React, { memo } from "react";
import { renderTxt } from "@/utils/common";

const TxtMsg = (props) => {
  const { message } = props;
  console.log("xxxxxxxxxxx");
  console.log(message);
  const quote = (message.ext && message.ext.quote) ? message.ext.quote : null;
  console.log(quote);
  return (
    <div className={s.main}>
      <div className={s.txt}>{renderTxt(message.msg)}</div>
      {quote? (
          <div>
            <div className={s.quote}>
              <span className={s.d}>"</span>
              <span>{quote.from}</span>:
              <span>{quote.msg}</span>
            </div>
          </div>
      ) : ("")}
    </div>
  );
}

export default memo(TxtMsg);
