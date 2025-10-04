<script lang="ts">
  let {children, href} = $props(); 
</script>

<a {href} class="p-4 text-xl font-semibold">{@render children()}</a>



