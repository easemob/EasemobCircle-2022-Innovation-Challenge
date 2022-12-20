import React, { memo } from "react";
import Icon from "../Icon";
import s from './index.module.less'

const CloseIcon = () => {

    return (
        <span className={s.close}>
            <Icon name="xmark" size="18px" />
        </span>
    );
};

export default memo(CloseIcon);
