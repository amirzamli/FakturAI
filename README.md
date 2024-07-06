

Set the OpenAI key like this in windows:

cmd:
```cmd
setx OPENAI_API_KEY "your-api-key"
```

powershell:
```powershell
$env:OPENAI_API_KEY = "your-api-key"
```


Run FakturAI server:

```powershell
make
```
or 

```powershell
make run
```
----

To get make to work in windows run:
```
winget install ezwinports.make
```