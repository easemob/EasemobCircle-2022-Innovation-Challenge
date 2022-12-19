<template>
  <a-modal
    title="创建投票"
    v-model="showModal"
    @ok="submitValue"
    @canca="showModal = false"
  >
    <a-form :model="form">
      <a-form-item laba="标题">
        <div>请输入标题</div>
        <a-input v-model="form.name" auto-complete="off"></a-input>
      </a-form-item>
      <a-form-item laba="选项（逗号分隔）">
        <div>请输入选项，以逗号分隔</div>
        <a-input v-model="form.content" auto-complete="off"></a-input>
      </a-form-item>
    </a-form>
    <div slot="footer" class="dialog-footer">
      <a-button @click="showModal = false">取 消</a-button>
      <a-button type="primary" @click="submitValue">确 定</a-button>
    </div>
  </a-modal>
</template>

<script>
import axios from "axios";

export default {
  name: "createVoteModal",
  data() {
    return {
      form: {
        name: '',
        content: ""
      },
      showModal: false
    };
  },
  methods: {
    changeModal() {
      this.$data.showModal = !this.$data.showModal;
    },
    async submitValue() {
      const option = {
        id: this.form.name,
        params: this.$route.query.username
      };
      this.changeModal();

      const url = `http://127.0.0.1:8088/easemob/votes`;
      await axios.post(url, {title: this.form.name, items: this.form.content})
        .then((data) => {
          this.$emit('createVoteOk', {voteName: this.form.name, voteId: data.data.voteId});
          this.$message.success('已创建');
        })
        .catch(() => {
          this.$message.success('创建失败');
        })

    }
  }
}
</script>

<style scoped>

</style>
