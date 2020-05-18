import photoshop

conn = photoshop.PhotoshopConnection(password='secret')
print(conn.get_layer_shape())