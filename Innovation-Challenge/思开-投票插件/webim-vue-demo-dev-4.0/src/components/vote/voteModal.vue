<template>
  <a-modal
    title="参与投票"
    v-model="showModal"
    @ok="submitValue"
    @canca="showModal = false"
  >
    <a-form :model="form" v-show="vote">
      <div>参与投票 {{ vote.title }} 的投票</div>
      <a-form-item v-for="(item,i) in vote.items" :key="i">
        <div class="item-container">
          <div class="left">
            <div style="margin: 12px;font-weight: bold">{{ i }}.</div>
            {{ item.name }}
          </div>
          <div class="right">
            <div class="button" @click="onVoteClick(item)">投票</div>
          </div>
        </div>
      </a-form-item>
    </a-form>
    <div class="stream-container">
      <div v-for="(item,i) in vote.streams">
        <div>{{ item.userId }} 已投票给 : {{ item.easemobVoteItemName }}</div>
      </div>
    </div>
    <div slot="footer" class="dialog-footer">
      <!--      <a-button @click="showModal = false">取 消</a-button>-->
      <!--      <a-button type="primary" @click="submitValue">确 定</a-button>-->
    </div>
  </a-modal>
</template>

<script>
import axios from "axios";
import WebIM from "../../utils/WebIM";

export default {
  name: "voteModal",
  data() {
    return {
      vote: {name: ""},
      form: {},
      showModal: false
    };
  },
  methods: {
    async changeModal(vote) {
      this.vote = vote;
      this.$data.showModal = !this.$data.showModal;
      const url = `http://127.0.0.1:8088/easemob/votes/${this.vote.voteId}`;
      await axios.get(url)
        .then((data) => {
          this.vote = data.data;
        })
        .catch(() => {
        })
    },
    async submitValue() {
      this.changeModal();
    },

    async onVoteClick(item) {
      const userId = WebIM.conn.user;
      const url = `http://127.0.0.1:8088/easemob/votes/${item.easemobVoteId}/${item.easemobVoteItemId}/vote?userId=${userId}`;
      await axios.post(url, {})
        .then((data) => {
        })
        .catch(() => {
        });
      this.changeModal();
    }
  }
}
</script>

<style scoped lang="less">
.item-container {
  display: flex;
  align-items: center;
  justify-content: space-between;

  .left {
    display: flex;
    align-items: center;
  }

  .right {
    display: none;

    .button {
      padding: 6px 24px;
      cursor: pointer;
      border: 1px solid #e0e0e0;
    }
  }

  &:hover {
    .right {
      display: flex;
    }
  }
}
</style>
