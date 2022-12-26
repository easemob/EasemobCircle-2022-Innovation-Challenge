import React, { memo, useRef } from "react";
import s from "./index.module.less";
import { connect } from "react-redux";
import ChannelGroupNoteForm from "./groupForm";
import Icon from "@/components/Icon";
import { Modal } from "antd";

const CreateGroupNote = ({ onClick, isEdit }) => {
  return (
    <div className={`${s.createBtn} circleBtn`} onClick={onClick}>
      {isEdit ? "加入" : "创建"}
    </div>
  );
};

const GroupNoteModel = (props) => {
  const { visible, setVisible } = props;
  const formRef = useRef();

  const isEdit = visible === "edit";

  const onOK = () => {
    formRef?.current.submit(
      () => {
        setVisible(false);
      },
      () => {
        setVisible(false);
      }
    );
  };

  return (
    <Modal
      width={544}
      title={isEdit ? "加入接龙" : "创建接龙"}
      visible={visible}
      destroyOnClose={true}
      closeIcon={<Icon name="xmark" color="#c7c7c7" size="16px" />}
      footer={<CreateGroupNote onClick={onOK} isEdit={isEdit} />}
      onCancel={() => {
        setVisible(false);
      }}
      className={s.channelFormModal}
    >
      <ChannelGroupNoteForm ref={formRef} threadId={""} isEdit={isEdit}/>
    </Modal>
  );
};

const mapStateToProps = ({ channel }) => {
  return {
    visible: channel.channelGroupNoteVisible
  };
};

const mapDispatchToProps = (dispatch) => {
  return {
    setVisible: (params) => {
      return dispatch({
        type: "channel/setChannelGroupNoteVisible",
        payload: params
      });
    }
  };
};

export default memo(connect(mapStateToProps, mapDispatchToProps)(GroupNoteModel));
