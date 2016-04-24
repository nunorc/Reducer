
import Reducer
import System.Environment
import qualified Data.ByteString.Lazy as BS
import qualified Data.Aeson as A

main = do
  [file] <- getArgs
  content <- BS.readFile file
  let Just input = A.decode content :: Maybe [String]
  putStr $ toDot $ reduce input

