import { Form, Input, Switch, message } from "antd";
import {
  memo,
  useState,
  forwardRef,
  useImperativeHandle,
  useEffect
} from "react";
import s from "./index.module.less";
import WebIM from "@/utils/WebIM";
import { useParams, useNavigate } from "react-router-dom";
import { connect } from "react-redux";
import {
  insertChannelList,
  createMsg,
  deliverMsg,
  updateLocalChannelDetail,
  formatterInputCount
} from "@/utils/common";

const ChannelGroupNoteForm = forwardRef((props, ref) => {
  const {insertGroupNoteMessage,userInfo,channelGroupNote} = props;
  const { isEdit = false } = props;
  const [form] = Form.useForm();
  const { serverId, channelId } = useParams();
  const [isPrivate, setIsPrivate] = useState(false);
  const navigate = useNavigate();

  const submit = (onSuccess = () => { }, onError = () => { }) => {
    if(isEdit){
        let newgroupNote = channelGroupNote;
        let joiners =  newgroupNote.joiners;
        if(joiners.indexOf(userInfo.username) < 0){
            joiners.push(userInfo.username);
            onSuccess();
        }else{
            message.info("您已参与该接龙");
            onSuccess();
        }
    }else{
        form
        .validateFields()
        .then((values = {}) => {
          if (!values.name) {
            message.info("请输入接龙名称!");
            return;
          }
          if (!values.description) {
            delete values.description;
          }
          console.log(userInfo)
          if(userInfo.username){
              values.creator = userInfo.username
          }
          values.joiners = [];
          insertGroupNoteMessage(values);
          onSuccess();
          }
        )
        .catch((e) => {
          onError();
        });
    }
    
  };

  useImperativeHandle(ref, () => ({
    submit
  }));


  return (
    <Form ref={ref} className="customForm" form={form} layout={"vertical"}>
      <Form.Item label="接龙名称" name="name">
        <Input
          showCount={{ formatter: formatterInputCount }}
          maxLength={16}
          disabled={isEdit ? true : false}
          placeholder={isEdit ? channelGroupNote.name : "请输入接龙名称"}
          autoComplete="off"
        />
      </Form.Item>
      <Form.Item label="接龙简介" name="description">
        <Input.TextArea
          rows={2}
          disabled={isEdit ? true : false}
          placeholder={isEdit ? channelGroupNote.description : "请输入接龙简介"} 
          maxLength={80}
          showCount={{ formatter: formatterInputCount }}
        />
      </Form.Item>
      {
        isEdit ? (<Form.Item label="参与人" name="description">
        <div style={{color:'white'}}>{channelGroupNote.joiners &&channelGroupNote.joiners.length >0 ? channelGroupNote.joiners.toString():""}</div>
        </Form.Item>):null
      }
    </Form>
  );
});
const mapStateToProps = ({ server, app,channel }) => {
  return {
    channelMap: server.channelMap,
    userInfo: app.userInfo,
    channelGroupNote:channel.channelGroupNote,
  };
};
const mapDispatchToProps = (dispatch) => {
  return {
    insertGroupNoteMessage: (params) => {
    return dispatch({
        type: "channel/insertGroupNoteMessage",
        payload: params
    });
    },
  };
};
export default memo(
  connect(mapStateToProps, mapDispatchToProps, null, { forwardRef: true })(
    ChannelGroupNoteForm
  )
);
