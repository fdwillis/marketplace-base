jQuery ->
	if $(".pagination").length
		$(window).scroll ->
			url = $(".pagination .next_page").attr("href")
			if url && $(window).scrollTop() > $(document).height() - $(window).height() - 30
				$(".pagination").text("Loading More Products")
				$.getScript(url)
			return
		$(window).scroll()