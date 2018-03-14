select * from opav.ofertas where num_os= 'FOMS13086-17' and centro_costos_gastos = 'A1111S1100027802'


update opav.ofertas set centro_costos_gastos = 'A1111S1100026802' , centro_costos_ingreso = 'A1111S1100026801' 
where num_os= 'FOMS13086-17' and centro_costos_gastos = 'A1111S1100027802';
