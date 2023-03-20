import { createApp } from 'vue'
import App from '../app.vue'
import Toast from "vue-toastification"
import "vue-toastification/dist/index.css"

document.addEventListener('DOMContentLoaded', () => {
  const Calendar = document.querySelector("#app")
  const userId = Calendar.getAttribute('data-user-id')
  const options = {
    // You can set your default options here
  }
  createApp(App, {userId: userId}).use(Toast, options).mount('#app')
})
