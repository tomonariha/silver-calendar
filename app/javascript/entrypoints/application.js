import { createApp } from 'vue'
import App from '../app.vue'
import Toast from "vue-toastification"
import "vue-toastification/dist/index.css"
import "../stylesheets/styles.scss"

document.addEventListener('DOMContentLoaded', () => {
  const Calendar = document.querySelector("#app")
  const userId = Calendar.getAttribute('data-user-id')
  const options = {
    timeout: 2000
  }
  createApp(App, {userId: userId}).use(Toast, options).mount('#app')
})
