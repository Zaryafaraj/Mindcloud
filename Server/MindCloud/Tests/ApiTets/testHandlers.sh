curl -X GET http://localhost:8000/Collections/
curl -X GET http://localhost:8000/Collections/name
curl -X PUT http://localhost:8000/Collections/name
curl -X POST http://localhost:8000/Authorize/3
curl -X DELETE http://localhost:8000/Collections/name
curl -d "collectionName=ali" http://localhost:8000/EC77E567-2924-4C9E-
BECA-36D25EA76431/Collections/

#Account_NO
EC77E567-2924-4C9E-BECA-36D25EA76431

curl -F "file=@XooML.xml;filename=Xooml.xml" -F "collectionName=alites65" http://localhost:8000/04B08CB7-17D5-493A-8ED1-E086FDC1327E/Collections
/curl -F "file=@XooML.xml;filename=Xooml.xml" -F "collectionName=alites65" http://localhost:8000/04B08CB7-17D5-493A-8ED1-E086FDC1327E/Collections/
curl -F "file=@thumbnail.jpg;filename=thumbnail.jpg" http://localhost:8000/04B08CB7-17D5-493A-8ED1-E086FDC1327E/Collections/aliLeila/Thumbnail


Stress test:
siege http://localhost:8000/04B08CB7-17D5-493A-8ED1-E086FDC1327E/Collections/ -c100 -t10s
siege http://localhost:8000/04B08CB7-17D5-493A-8ED1-E086FDC1327E/Test/ -c100 -t20s
siege http://localhost:8000/Authorize/http://localhost:8000/Authorize/04B08CB7-17D5-493A-8ED1-E086FDC13274 -c100 -t20s -v
siege http://localhost:8000/04B08CB7-17D5-493A-8ED1-E086FDC1327E/Collections/mo/Thumbnail -c100 -t20s

Authorization
curl -X GET http://localhost:8000/Authorize/04B08CB7-17D5-493A-8ED1-E086FDC13276
curl -X POST http://localhost:8000/Authorize/04B08CB7-17D5-493A-8ED1-E086FDC13276


CURL with proxy:
curl -x http://127.0.0.1:8888 -F "file=@XooML.xml;filename=Xooml.xml" -F "collectionName=alites65" http://localhost:8000/04B08CB7-17D5-493A-8ED1-E086FDC1327E/Collections