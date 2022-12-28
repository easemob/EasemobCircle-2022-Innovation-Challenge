import s from "./index.module.less";
import React, { memo } from "react";
import { Card ,Badge} from 'antd';
const { Meta } = Card;

const TestExt = (props) => {
  const { message } = props;
  return (
      <div className={s.main}>
          <Badge.Ribbon text="Hippies">
              <Card title="Pushes open the window" size="small">
                  TestExtTestExtTestExtTestExtTestExtTestExtTestExt
              </Card>
          </Badge.Ribbon>
      </div>
  );
};

export default memo(TestExt);
