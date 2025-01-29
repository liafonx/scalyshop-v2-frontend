<template>
  <b-list-group-item
    class="d-flex align-items-center justify-content-between w-"
  >
    <div class="d-flex gap-3">
      <img
        alt="Product"
        src="../assets/game.png"
        style="width: 48px; height: auto"
      />
      <div class="text-start">
        <h5 class="mb-1 fw-bold">{{ product.name }}</h5>
        <!-- <small>{{ product?._id }}</small> -->
        <small>{{ product?.category }}</small>
      </div>
    </div>
    <div class="d-flex gap-3 align-items-center">
      <h3 class="fw-bold m-0">{{ product.price }} kr</h3>
      <div>
        <b-button
          type="button"
          variant="link"
          v-b-tooltip.hover
          title="Add To Cart"
          @click="$emit('order-product', product._id)"
        >
          <img alt="Add To Cart" src="../assets/addtocart.svg" />
        </b-button>
        <b-button
          type="button"
          variant="link"
          @click="removeFavorite(product._id)"
          v-b-tooltip.hover
          title="Remove From Favorite"
          v-if="favorites?.includes(product._id)"
        >
          <img alt="remove Favorite" src="../assets/bag-heart-fill.svg" />
        </b-button>
        <b-button
          type="button"
          variant="link"
          @click="addFavorite(product._id)"
          v-b-tooltip.hover
          title="Add To Favorite"
          v-if="!favorites?.includes(product._id)"
        >
          <img alt="add to Favorite" src="../assets/bag-heart.svg" />
        </b-button>
      </div>
    </div>
  </b-list-group-item>
</template>

<script>
import { Api } from "@/Api";

export default {
  name: "product-item",
  props: ["product", "favorites"],
  methods: {
    async addFavorite(productId) {
      Api.post("favorites", {
        productId,
      })
        .then(() => {
          this.$emit("get-favorites");
        })
        .catch((error) => {
          console.log(error);
        });
    },
    async removeFavorite(productId) {
      Api.delete(`/favorites/${productId}`)
        .then(() => {
          this.$emit("get-favorites");
        })
        .catch((error) => {
          console.log(error);
        });
    },
  },
};
</script>

<style scoped>
img {
  width: 24px;
  object-fit: contain;
}
</style>
