<template>
  <b-list-group-item>
    <img alt="Product" src="../assets/game.png" />
    {{ product.name }} - ( {{ product.price }}kr )
    <b-button
      type="button"
      variant="link"
      @click="$emit('order-product', product._id)"
    >
      <img alt="Add To Cart" src="../assets/addtocart.jpg" />
    </b-button>
    <b-button
      type="button"
      variant="link"
      @click="removeFavorite(product._id)"
      v-if="favorites?.includes(product._id)"
    >
      <img alt="remove Favorite" src="../assets/bag-heart.svg" />
    </b-button>
    <b-button
      type="button"
      variant="link"
      @click="addFavorite(product._id)"
      v-if="!favorites?.includes(product._id)"
    >
      <img alt="add to Favorite" src="../assets/bag-heart-fill.svg" />
    </b-button>
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
  width: 33px;
  margin-right: 10px;
}
</style>
