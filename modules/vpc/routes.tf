###
## Private
###
resource "aws_route_table" "private" {
  count = var.zones_count
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "private_${count.index}"
  }
}

resource "aws_route_table_association" "private_rt_assoc" {
  count           = var.zones_count
  subnet_id       = aws_subnet.private[count.index].id
  route_table_id  = aws_route_table.private[count.index].id
}