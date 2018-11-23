class InvoicePdf < Prawn::Document
	
	def initialize(order, view)
		super()
		@order = order
		@view = view
		orderno_table
		billed_to
		shipped_to
		order_date
		product_table(@view)
		total_price(@view)
	end	

	def orderno_table
		data = [[ make_cell("Order# #{@order.id}", :borders=>[:bottom])]] 
	  table data, :position => :left, width: 540 do
	    row(0).align = :left
			row(0).size = 18
	    # columns(0).border_widths = 0
	  end
	end	

	def billed_to
		move_down 10 
		# text 'Billed To:', size: 10, style: :bold, align: :left
		data = [["Billed To:"],["#{@order.first_name + " "  + @order.last_name} 
						#{@order.email} 
						#{@order.mobile_number}"]  ]
	  table data, :position => :left, width: 500 do
	  	row(0).size = 10
	  	row(0).font_style = :bold
	    row(0..3).align = :left
			row(0..3).size = 10
	    columns(0).border_widths = 0
	  end
	end

	def shipped_to 
		move_up 60
		text 'Shipped To:', size: 10, style: :bold, align: :right
		address = @order.addresses.first
		if not @order.addresses.count == 0
			data = [["#{address.line_1}
				#{address.line_2 if address.line_2.present?}
				#{address.line_3 if address.line_3.present?}
				#{address.city}
				#{address.state}
				#{address.pincode}"] ]
		elsif not @order.order_items.last.nil? and not @order.order_items.last.provider.nil?
			if @order.order_items.last.provider.image.present?
				data = [[{:scale => 0.1,  :position => :right, :image => open("https:#{@order.order_items.last.provider.image.url.split('?').first}") }],["#{@order.order_items.last.provider.user.company}"]]
			else
				data = [["#{@order.order_items.last.provider.user.company}"]]
			end
		end
	  table data, :position => :right, :width => 510  do
	    row(0..3).align = :right
			row(0..3).size = 9
			row(0).size = 10
	    columns(0).border_widths = 0
	  end
	end

	def order_date
		move_down 25
		data = [["Order Date:"], ["#{@order.order_date.strftime("%m/%d/%Y")}"]] 
	  table data, :position => :left, width: 540 do
	    row(0).align = :left
			row(0).font_style = :bold
			row(0).size = 10
			row(1).size = 9
	    columns(0).border_widths = 0
	  end
	end

	def product_table(view)
		move_down 10
		table products_data(view),  width: 510 do
			# columns(0..5).border_widths = 0
			columns(0).width = 130 
			columns(1).width = 130 
			columns(2).width = 120 
			columns(2).align = :center 
			columns(3).width = 130 
			columns(3).align = :right 
			# columns(4).width = 120
			# columns(4).align = :right    
		end 
	end

	def products_data(view)
		text 'Products', size: 11, style: :bold, align: :left
		data = [[make_cell("Name",  :borders=>[:bottom]) , make_cell("Price",  :borders=>[:bottom]), make_cell("Quantity",  :borders=>[:bottom]) , make_cell("Total",  :borders=>[:bottom])]] +
		@order.order_items.each.map {|order_item| 
			[ make_cell(order_item.product.name, :borders=>[:bottom]), make_cell("#{view.humanized_money_with_symbol order_item.price}", :borders=>[:bottom]), make_cell(order_item.quantity, :borders=>[:bottom]) , make_cell("#{view.humanized_money_with_symbol order_item.order_item_total_price}", :borders=>[:bottom])]
		}
	end


	def total_price(view)
		move_down 20
		data = [["Order Total: #{view.humanized_money_with_symbol @order.total_price}"]] 
	  table data, :position => :right, width: 540 do
	    row(0).align = :right
			row(0).size = 18
	    columns(0).border_widths = 0
	  end
	end
end	
